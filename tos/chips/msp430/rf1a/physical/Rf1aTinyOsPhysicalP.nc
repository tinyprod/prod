/*
 * Copyright (c) 2010 People Power Co.
 * All rights reserved.
 *
 * This open source code was developed with funding from People Power Company
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

#include "Rf1aPacket.h"

/** This module bridges the Rf1aPhysical realm with the lowest-level
 * TinyOS message_t-based Send and Receive operations, and provides
 * SplitControl support.
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

generic module Rf1aTinyOsPhysicalP() {
  provides {
    interface SplitControl;
    interface Send[uint8_t frame_type];
    interface Receive[uint8_t frame_type];
  }
  uses {
    interface Resource;
    interface Rf1aPhysical;
    interface Rf1aPhysicalMetadata;
    interface Packet;
    interface Rf1aPacket;
  }
} implementation {

  /** Bare physical header structure */
  typedef rf1a_ieee154_t phy_header_t;

  /** Get a cast pointer to the physical layer header */
  phy_header_t* header (message_t* msg) { return (phy_header_t*)(msg->data - sizeof(phy_header_t)); }

  /** Get a cast pointer to the frame control field union */
  ieee154_fcf_t* fcf (message_t* msg) { return (ieee154_fcf_t*)(& header(msg)->fcf); }

  /** Packet metadata structure */
  typedef rf1a_metadata_t metadata_t;

  /** Get a cast pointer to the metadata structure */
  metadata_t* metadata (message_t* msg) { return call Rf1aPacket.metadata(msg); }

  // Forward declaration
  void setReceiveBuffer (message_t* mp);

  /** States for managing the TEP115-imposed SplitControl interface.
   *
   * The SplitControl interface links with the Resource interface, and
   * becomes the primary mechanism for turning the support for the
   * network stack of this protocol on and off.  A start involves
   * requesting the radio resource, and is complete when that request
   * is granted.  A stop releases the resource, turning off the
   * radio.
   */
  enum {
    /** State prior to invocation of SplitControl.start() or after
     * signalling of SplitControl.stopDone(). */
    SCS_off,
    /** State between invocation of SplitControl.start() and
     * signalling of SplitControl.startDone().  We are waiting for the
     * radio resource to be granted. */
    SCS_starting,
    /** Radio is on. */
    SCS_on,
    /** State between invocation of SplitControl.stop(0 and signalling
     * of SplitControl.stopDone().  We are waiting for radio
     * transmissions to cease and the radio resource to be
     * released. */
    SCS_stopping,
  };

  /** The current state of the bridge as far as SplitControl is concerned. */
  uint8_t split_control_state;

  /** States of the transmit subsystem. */
  enum {
    /** No transmission is in effect */
    TXS_idle,
    /** System is transmitting a message through the Send interface */
    TXS_active,
  };

  /** Current status of the transmit subsystem */
  uint8_t tx_state;

  /** The result code from the physical layer send. */
  int tx_result;

  /** The pointer to the message currently being sent.  Valid only
   * when tx_state is not TXS_idle. */
  message_t* tx_message;

  /** An owned buffer that is used for receiving messages during times
   * when there is no other message buffer available: specifically,
   * upon initial start of the radio. */
  message_t rx_buffer;

  /** A pointer to the message structure currently pinned for use in
   * physical receive operations.  This may or may not be
   * rx_buffer. */
  message_t* rx_message;
  
  /** The number of octets in the received message.  Only valid for
   * the duration between the async Rf1aPhysical.receiveDone event and
   * the execution of the receiveDone_task.
   */
  unsigned int rx_count;

  command error_t SplitControl.start() {
    atomic {
      /* Conform to TEP108's strict definition for this function. */
      switch (split_control_state) {
        case SCS_on:
          return EALREADY;
          break;
        case SCS_starting:
          return SUCCESS;
          break;
        case SCS_stopping:
          return EBUSY;
          break;
        case SCS_off:
          if (SUCCESS == call Resource.request()) {
            split_control_state = SCS_starting;
            return SUCCESS;
          }
          //FALLTHRU
        default:
          return FAIL;
      }
    }
  }

  command error_t SplitControl.stop () { 
    atomic {
      /* Conform to TEP108's strict definition for this function. */
      switch (split_control_state) {
        case SCS_off:
          return EALREADY;
          break;
        case SCS_stopping:
          return SUCCESS;
          break;
        case SCS_starting:
          return EBUSY;
          break;
        case SCS_on:
          if (SUCCESS == call Resource.release()) {
            split_control_state = SCS_stopping;
            return SUCCESS;
          }
          //FALLTHRU
        default:
          return FAIL;
      }
    }
  }

  event void Resource.granted () {
    /* Upon granting the resource, the radio configuration has been
     * reset, and there are no buffers provided for receives.
     * Configure a default buffer.
     */
    call Packet.clear(&rx_buffer);
    setReceiveBuffer(&rx_buffer);
    atomic {
      split_control_state = SCS_on;
      tx_state = TXS_idle;
    }
    signal SplitControl.startDone(SUCCESS);
  }

  task void stopDone_task () {
    atomic split_control_state = SCS_off;
    signal SplitControl.stopDone(SUCCESS);
  }

  async event void Rf1aPhysical.released () {
    post stopDone_task();
  }

  default event void SplitControl.startDone (error_t error) { }
  default event void SplitControl.stopDone (error_t error)  { }

  /** Feed the underlying radio a new buffer into which messages
   * should be received.
   *
   * To simplify the control logic, we use single-use message buffers.
   *
   * @param mp The buffer to be used for the next message.  If null,
   * the existing buffer is re-used.
   */
  void setReceiveBuffer (message_t* mp) {
    atomic {
      int rv;
      uint8_t* hp;

      if (mp) {
        rx_message = mp;
      }

      /* Figure out where the message starts. */
      hp = (uint8_t*)header(rx_message);

      /* Tricksy: limit the received length so it stops at the end of
       * the message_t structure. */
      rv = call Rf1aPhysical.setReceiveBuffer(hp, ((uint8_t*)(rx_message + 1)) - hp, TRUE);

      /* What do we do if this fails?  Really, it shouldn't: the only
       * way it would is if the radio was actively receiving into an
       * already assigned buffer, and since we're (supposedly) the
       * only place where receive buffers are provided, and we provide
       * them as single-use, this "can't happen". */
    }
  }

  /** Task to eliminate warning about invoking Send.sendDone from
   * async Rf1aPhysical.sendDone.
   */
  task void sendDone_task () {
    message_t* msg;
    int result;

    atomic {
      result = tx_result;
      msg = tx_message;
      tx_message = 0;
      tx_state = TXS_idle;
    }
    signal Send.sendDone[fcf(msg)->frame_type](msg, result);
  }

  async event void Rf1aPhysical.sendDone (int result) {
    atomic {
      tx_result = result;
    }
    post sendDone_task();
  }

  command error_t Send.send[uint8_t frame_type] (message_t* msg, uint8_t len) {
    int rv = SUCCESS;
    uint8_t* packet_start = (uint8_t*)header(msg);
    unsigned int packet_length = sizeof(phy_header_t) + len;
    ieee154_fcf_t* fcfp = fcf(msg);

    atomic {
      if (SCS_on != split_control_state) {
        rv = EOFF;
      } else if (TXS_idle != tx_state) {
        rv = EBUSY;
      } else {
        fcfp->frame_type = frame_type;
        rv = call Rf1aPhysical.send(packet_start, packet_length);
        if (SUCCESS == rv) {
          tx_message = msg;
          tx_state = TXS_active;
          tx_result = SUCCESS;
        }
#if 0
        {
          uint8_t* bp = packet_start;
          unsigned int bc = packet_length;
          printf("Sending %u at %p got %d: \r\n", bc, bp, rv);
          while (0 < bc--) {
            printf(" %02x", *bp++);
          }
          printf("\r\n");
        }
#endif
      }
    }
    return rv;
  }

  command error_t Send.cancel[uint8_t frame_type] (message_t* msg) {
    /* In fact, we could cancel a send, though it might get ugly on
     * the other end.  For now, we don't. */
    return FAIL;
  }

  default event void Send.sendDone[uint8_t frame_type] (message_t* msg, error_t error) { }

  command uint8_t Send.maxPayloadLength[uint8_t frame_type] () {
    if (IEEE154_TYPE_DATA == frame_type) {
      return TOSH_DATA_LENGTH;
    }
    // For non-DATA frames, length is unknown
    return 0;
  }

  command void* Send.getPayload[uint8_t frame_type] (message_t* msg, uint8_t len) {
    return ((len+sizeof(phy_header_t)) <= TOSH_DATA_LENGTH) ? (void*)msg->data : 0;
  }

  default event message_t* Receive.receive[uint8_t frame_type] (message_t* msg, void* payload, uint8_t len) { return msg; }

  async event void Rf1aPhysical.receiveStarted (unsigned int length) { }

  task void receiveDone_task () {
    unsigned int count;
    unsigned int payload_length;
    message_t* mp;
    uint8_t frame_type;

    atomic {
      mp = rx_message;
      rx_message = 0;
      count = rx_count;
    }
    frame_type = fcf(mp)->frame_type;
    /* Propagate the successful receive up the stack, installing the returned
     * message buffer for use in the next reception. */
    payload_length = count - sizeof(phy_header_t);
    if (IEEE154_TYPE_DATA == frame_type) {
      metadata_t* mdp = metadata(mp);
      call Rf1aPhysicalMetadata.store(mdp);
      mdp->payload_length = count;
    }
#if 0
    {
      uint8_t* bp = (uint8_t*)header(mp);
      unsigned int bc = count;

      printf("Receive %u at %p in %p, loc %p:\r\n", count, bp, mp, mp->data);
      while (0 < bc--) {
        printf(" %02x", *bp++);
      }
      printf("\r\n");
    }
#endif
    setReceiveBuffer(signal Receive.receive[frame_type](mp, mp->data, payload_length));
  }

  async event void Rf1aPhysical.receiveDone (uint8_t* buffer,
                                             unsigned int count,
                                             int result) {
    if (SUCCESS == result) {
      /* Store the message size and result.  We can ignore the buffer,
       * since we know it went into the current rx_message */
      atomic {
        rx_count = count;
        post receiveDone_task();
      }
    } else {
      /* TinyOS's receive notification does not provide a way to
       * indicate a failure, so we drop those at the physical layer.
       * If you care, monitor this event.  We'll just re-use the
       * current buffer for the next message. */
      setReceiveBuffer(0);
    }
  }

  async event void Rf1aPhysical.receiveBufferFilled (uint8_t* buffer,
                                                     unsigned int count) {
    /* We can ignore these, because we're doing single-use message
     * buffers, so we get the notification in receiveDone.  It may be
     * that, in a fast system, this event gets invoked by the physical
     * layer to ask for a new buffer to store stuff into, but until
     * the receiveDone_task finishes interacting with the upper layers
     * we don't have a buffer to provide. */
  }

  async event void Rf1aPhysical.frameStarted () { }
  async event void Rf1aPhysical.clearChannel () { }
  async event void Rf1aPhysical.carrierSense () { }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
