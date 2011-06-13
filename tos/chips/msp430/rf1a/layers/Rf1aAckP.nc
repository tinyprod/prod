/*
 * Copyright (c) 2010 People Power Co.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

generic module Rf1aAckP () {
  provides {
    interface Send;
    interface Receive;
    interface PacketAcknowledgements;
  }
  uses {
    interface Alarm<T32khz, uint16_t> as AckWaitAlarm;
    interface Send as SubSend;
    interface Receive as SubReceive;
    interface Send as AckSend;
    interface Receive as AckReceive;
    interface Rf1aPhysicalMetadata;
    interface Rf1aPacket;
  }
} implementation {

#include "Ieee154.h"

  /** Bare physical header structure */
  typedef rf1a_ieee154_t phy_header_t;  

  /** Get a cast pointer to the physical layer header */
  phy_header_t* header (message_t* msg) { return (phy_header_t*)(msg->data - sizeof(phy_header_t)); }

  /** Get a cast pointer to the frame control field union */
  ieee154_fcf_t* fcf (message_t* msg) { return (ieee154_fcf_t*)(& header(msg)->fcf); }

  /** The structure used for acknowledgments.
   *
   * @note The IEEE 802.15.4-2006 specification assumes that precise
   * timing is available to identify the message for which an ack is
   * received, and consequently elides the source and destination
   * addresses from the acknowledgment frame.  Since the 802.15.4
   * implementation supported by this implementation is not clocked at
   * the symbol level, precise timing cannot be assumed and this
   * assumption is invalid.  Therefore, we do not use IEEE
   * 802.15.4-2006 acknowledgment frames, but instead use a header
   * that includes source and destination addresses.  Which might as
   * well be the standard 802.15.4 header, though it need not always
   * be so.
   */
  typedef rf1a_ieee154_t ack_t;

  /** The structure used for acknowledgement messages.
   * 
   * We don't use a message_t because that's way too large given we
   * have no payload and no need for a metadata section.  However, we
   * can't use a raw rf1a_ieee154_t because the interfaces expect a
   * message_t pointer, and the rf1a_ieee154_t is a 9-byte structure
   * with two-byte alignment requirements: casting between pointers
   * screws up the offsets.  Besides, somebody might have stuck
   * something else in the header union as well.
   */
  typedef nx_struct {
    nx_uint8_t header[sizeof(message_header_t)];
    nx_uint8_t data[1];
  } ack_message_t;

  /** State machine for acknowledgment processing on the transmit
   * side.  Note that the lower-level send might involve
   * low-power-listening, with significant delays and intervening
   * receives between the SubSend.send() and the corresponding
   * SubSend.sendDone().  We will assume, however, that although
   * SubSend.send() is not asynchronous, nothing during that
   * invocation can affect the transmission state machine.
   *
   * The TinyOS Alarm interface does not provide clear guarantees that
   * allow us to break out of the state machine (e.g., no guarantee on
   * whether a fired() event will fire when stopping the alarm).
   * Therefore, receiving an ack when the AckWaitAlarm may be set will
   * be processed through that alarm's fired() event.
   */
  enum {
    /** State indicates there is no active transmission that requires
     * an acknowledgment.  Transition to TX_S_sending occurs on
     * upper level send.  AckWaitAlarm is not set. */
    TX_S_idle,
    /** State indicates there is an active transmission that requires
     * acknowledgment, and we are between having successfully invoked
     * the low level send and receiving its sendDone.  Transition to
     * TX_S_waiting occurs on lower level sendDone.  AckWaitAlarm is
     * not set. */
    TX_S_sending,
    /** State indicates there is an active transmission for which we
     * have completed an initial or retransmit send and are waiting on
     * the timeout.  AckWaitAlarm is set.  Always transitions to
     * TX_S_alarmFired, and only by the firing of the alarm. */
    TX_S_waiting,
    /** State indicates that the alarm has fired, and we're waiting
     * for the corresponding task to get executed.  AckWaitAlarm is
     * not set. */
    TX_S_alarmFired,

    /** A mask used to extract the state identifier from the state
     * variable, excluding meta-information like whether the
     * acknowledgment had been asynchronously received. */
    TX_S_MASK = 0x0F,
    /** Bit set to indicate that an ACK was received while in the
     * current state.  See SubReceive.receive() for transition
     * details. */
    TX_S_ACKED = 0x80,
  };

  /** The current transmission acknowledgment processing state */
  uint8_t tx_state;

  /** The number of retries left for the current send. */
  uint8_t tx_attempts_remaining;

  /** The message being transmitted that requires acknowledgments.
   * Only valid when tx_state is not TX_S_idle. */
  message_t* tx_message;

  /** The length paired with tx_message. */
  uint8_t tx_length;

  /** The result code to be provided when signaling send completion */
  error_t tx_result;

  /** TRUE iff the most packet for which the next sendDone will be
   * signalled was acknowledgeable and acknowledged. */
  bool tx_acked;

  /** State machine for acknowledgment processing on the receive side.
   * Upon receipt of a message that should be acknowledged, a base
   * rf1a_ieee154_t header is initialized containing the DSN of the
   * incoming message and is transmitted back to the sender.  */
  enum {
    /** State indicates that no transmission of an acknowledgment is
     * in progress. */
    RX_S_idle,
    /** State indicates that an acknowledgment has been sent, but the
     * AckSend interface has not indicated completion of the
     * transmission. */
    RX_S_transmitting,
  };
  /** The current receive acknowledgment processing state */
  uint8_t rx_state;

  /** The structure used to transmit an acknowledgment message */
  ack_message_t ack_message;

  enum {
    /** The number of 32KHz ticks to wait, after completion of
     * sendDone, before assuming the remote has failed to acknowledge
     * the transmission. */
    CFG_macAckWaitDuration_32k = 3277, // 100ms

    /** The number of retransmissions allowed.  Note that a value of 0
     * is legitimate, and requires acknowledgment on the first
     * transmission. */
    CFG_macMaxFrameRetries = 4,
  };

  /** Signal the upper layer that the send has completed, and reset
   * the state machine.
   */
  void signalSendDone_ () {
    message_t* msg;
    error_t rv;

    /* tx_acked should have been correctly set by whoever invoked this
     * function, so that it's valid at the time the signal is
     * delivered.
     */
    atomic {
      tx_state = TX_S_idle;
      msg = tx_message;
      tx_message = 0;
      rv = tx_result;
    }
    if (msg) {
      signal Send.sendDone(msg, rv);
    }
  }

  /** Helper function to transition the state machine to TX_S_waiting
   * and configure the alarm for the appropriate delay.  Must only be
   * invoked while in an atomic section.
   */
  void transitionToWaiting_atomic_ () {
    call AckWaitAlarm.start(CFG_macAckWaitDuration_32k);
    tx_state = TX_S_waiting;
  }

  /** Process a completed low-level send operation.
   *
   * Transition to the appropriate state, which depends on the result
   * of the send, whether an ack has been received, and whether there
   * are retry attempts remaining.  Returns a flag to indicate when
   * the state machine should exit and the caller be notified of the
   * ultimate disposition of the send.
   * 
   * @param result the result of the send
   * @return TRUE iff the caller should invoke signalSendDone_
   */
  bool completeSend_atomic_ (error_t result) {
    bool rv = tx_acked = TX_S_ACKED & tx_state;
    if (! tx_acked) {
      if ((SUCCESS != result) && (0 == tx_attempts_remaining)) {
        rv = TRUE;
      } else {
        transitionToWaiting_atomic_();
      }
    }
    return rv;
  }

  /** Process state changes resulting from, or occurring after, an ack alarm. */
  task void ackWaitAlarmFired_task () {
    bool signal_done = FALSE;
    atomic {
      signal_done = tx_acked = TX_S_ACKED & tx_state;
      if (! tx_acked) {
        /* If we're waiting for a result, and haven't received an ack,
         * and there are no retransmit attempts remaining, consider this
         * a failure. */
        if (0 == tx_attempts_remaining--) {
          tx_result = ENOACK;
          signal_done = TRUE;
        }
      }
      if (! signal_done) {
        tx_state = TX_S_sending;
      }
    }
    if (! signal_done) {
      error_t rv = call SubSend.send(tx_message, tx_length);
      if (SUCCESS != rv) {
        atomic {
          /* If we won't get a sendDone, do now what it would have done.
           * Yes, if this is the last retransmission, we could fail now,
           * but we'll optimize that after things work. */
          signal_done = completeSend_atomic_(rv);
        }
      }
    }
    if (signal_done) {
      signalSendDone_();
    } 
  }

  command error_t Send.send (message_t* msg, uint8_t len) {
    error_t rv = SUCCESS;
    bool need_ack = FALSE;

    atomic {
      phy_header_t* hp = header(msg);
      ieee154_fcf_t* fcfp = fcf(msg);

      /* TEP116 specifies no nested sends, even though we could do
       * transmit non-ack messages while awaiting an ack. */
      if (TX_S_idle != tx_state) {
        return EBUSY;
      }

      /* IEEE 802.15.4-2006 section 7.5.6.4: data and MAC command
       * frames may request acks, as long as they are not broadcast.
       * AcknowledgmentRequest must be zero for beacon and ack
       * frames, and anything broadcast.  We can't enforce that, so we
       * just assume it. */
      if ((IEEE154_TYPE_DATA == fcfp->frame_type)
          && fcfp->ack_request
          && (IEEE154_BROADCAST_ADDR != hp->dest)) {
        /* Need an ack, but we can only wait for one at a time. */
        need_ack = TRUE;
        tx_state = TX_S_sending;
      }
      /* This send has not been acked, even if we're processing
       * another one that could be. */
      tx_acked = FALSE;
    }
    rv = call SubSend.send(msg, len);

    /* Correct state based on success or failure if this packet
     * requires acknowledgment. */
    if (need_ack) {
      atomic {
        if (SUCCESS == rv) {
          /* Success: store the relevant information so we can execute
           * the state machine to eventually provide a sendDone signal
           * to the caller. */
          tx_attempts_remaining = CFG_macMaxFrameRetries;
          tx_message = msg;
          tx_length = len;
          tx_result = SUCCESS;
        } else {
          /* Failure: the machine stops now, and the error is returned
           * to the caller. */
          tx_state = TX_S_idle;
        }
      }
    }

    return rv;
  }

  command error_t Send.cancel(message_t* msg) {
    /* @TODO@ We explicitly disallow cancelling transmission until
     * such time as the appropriate cleanup can be identified.
     */
    return FAIL;
  }

  command uint8_t Send.maxPayloadLength() { return call SubSend.maxPayloadLength(); }

  command void* Send.getPayload(message_t* msg, uint8_t len) { return call SubSend.getPayload(msg, len); }

  async event void AckWaitAlarm.fired () {
    atomic {
      /* Set state to TX_S_alarmFired, preserving TX_S_ACKED if set */
      tx_state = (tx_state & ~TX_S_MASK) | TX_S_alarmFired;
    }
    post ackWaitAlarmFired_task();
  }

  default event void Send.sendDone(message_t* msg, error_t error) { }

  event void SubSend.sendDone (message_t* msg, error_t error) {
    bool do_bypass_signal = TRUE;
    bool do_state_signal = FALSE;

    atomic {
      uint8_t bare_state = TX_S_MASK & tx_state;

      /* Only interested if we're awaiting a sendDone that's relevant
       * to the transmission ack state. */
      if (TX_S_sending == bare_state) {
        /* This is paired with one of our send() invocations, so don't
         * signal this result.  If the ack has come in, do complete
         * the state machine. */
        do_bypass_signal = FALSE;
        do_state_signal = completeSend_atomic_(error);
      }
    }
    if (do_state_signal) {
      signalSendDone_();
    } else if (do_bypass_signal) {
      signal Send.sendDone(msg, error);
    }
  }

  default event message_t* Receive.receive (message_t* msg, void* payload, uint8_t len) { return msg; }

  enum {
    /** Discard Frame Type, Acknowledgment Requested, and Frame Pending */
    FCF_ACK_PRESERVE = ~ ((IEEE154_TYPE_MASK << IEEE154_FCF_FRAME_TYPE)
                          | (1 << IEEE154_FCF_ACK_REQ)
                          | (1 << IEEE154_FCF_FRAME_PENDING)),

    /** Value to set in cleared acknowledgment FCF */
    FCF_ACK_FIXED = (IEEE154_TYPE_ACK << IEEE154_FCF_FRAME_TYPE),
  };

  event message_t* SubReceive.receive (message_t* msg, void* payload, uint8_t len) {
    phy_header_t* hp = header(msg);
    ieee154_fcf_t* fcfp = fcf(msg);

    if (fcfp->ack_request) {
      /* Need to transmit an Ack, though we won't if we're still
       * waiting for one to finish transmitting. */
      bool invoke_send = FALSE;
      atomic {
        if (RX_S_idle == rx_state) {
          ack_t* ap = (ack_t*)header((message_t*)&ack_message);
          *ap = *hp;

          /* NB: Assumption is src and dest address modes are the same. */
          ap->fcf = (ap->fcf & FCF_ACK_PRESERVE) | FCF_ACK_FIXED;
          ap->dest = hp->src;
          ap->src = hp->dest;
          rx_state = RX_S_transmitting;
          invoke_send = TRUE;
        }
      }
      if (invoke_send) {
        error_t rv = call AckSend.send((message_t*)&ack_message, 0);
        if (SUCCESS != rv) {
          /* If the transmission didn't succeed, reset the state so we
           * don't wait for PhySend.sendDone(). */
          atomic {
            rx_state = RX_S_idle;
          }
        }
      }
    }
    return signal Receive.receive(msg, payload, len);
  }

  event message_t* AckReceive.receive (message_t* msg, void* payload, uint8_t len) {
    phy_header_t* hp = header(msg);

    atomic {
      uint8_t bare_state = TX_S_MASK & tx_state;
      if ((TX_S_idle != bare_state) && (! (TX_S_ACKED & tx_state))) {
        ack_t* ap = (ack_t*)header(tx_message);
        bool acked = ((hp->src == ap->dest)
                      && (hp->dest == ap->src)
                      && (hp->dsn == ap->dsn));
        if (acked) {
          /* Set the flag indicating the ack was received
           * successfully.  If we're waiting, short the alarm;
           * otherwise the signal will be handled at the point where
           * the next transition would occur (sendDone or alarm task
           * execution). */
          tx_state |= TX_S_ACKED;
          tx_result = SUCCESS;
          if (TX_S_waiting == bare_state) {
            call AckWaitAlarm.start(0);
          }
          /* Store what we hope is still the corresponding metadata. */
          call Rf1aPhysicalMetadata.store(call Rf1aPacket.metadata(tx_message));
        }
      }
    }
    return msg;
  }

  event void AckSend.sendDone (message_t* msg, error_t error) {
    atomic {
      /* Completed sending the acknowledgment; reset the state.  Note
       * that it doesn't matter whether the send was successful, at
       * least as far as state management goes.
       */
      if (RX_S_transmitting == rx_state) {
        rx_state = RX_S_idle;
      }
    }
  }

  async command error_t PacketAcknowledgements.requestAck( message_t* msg ) {
    ieee154_fcf_t* fcfp = fcf(msg);

    /* IEEE 802.15.4-2006 section 7.5.6.4: this should be rejected for
     * broadcast messages, but TinyOS interfaces probably haven't set
     * the destination address yet, so we can't check that.
     */
    fcfp->ack_request = 1;
    return SUCCESS;
  }

  async command error_t PacketAcknowledgements.noAck( message_t* msg ) {
    ieee154_fcf_t* fcfp = fcf(msg);
    fcfp->ack_request = 0;
    return SUCCESS;
  }

  async command bool PacketAcknowledgements.wasAcked(message_t* msg) {
    atomic return !!tx_acked;
  }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
