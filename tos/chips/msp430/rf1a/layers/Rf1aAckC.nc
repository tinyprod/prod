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

/**
 * Component to assist with retransmission and acknowledgement
 * processing of 802.15.4 packets using the RF1A radio stack.
 *
 * This component must be wedged into the network stack between a
 * (upper) level that configures the packet's DSN, and the lower level
 * that transmits it.  The lower level Send operation may be invoked
 * multiple times for a single packet.  If the first attempt to send
 * the message fails immediately, that failure is immediately
 * communicated to the caller.  However, if the first send succeeds,
 * retransmit sends are implicitly treated as successful.
 *
 * @TODO@ prevent the stack from being shut down while an ack
 * transmission is active.
 *
 * @note The IEEE 802.15.4-2006 specification presumes that timing is
 * adequate to identify the message for which an ack is received.
 * Since the 802.15.4 implementation supported by this implementation
 * is not clocked at the symbol level, this assumption is invalid.
 * Therefore, we do not use IEEE 802.15.4-2006 acknowledgment frames,
 * but instead use a header that includes source and destination
 * addresses.
 *
 * @note This component mixes retransmission with acknowledgment
 * processing.  These could be separated by placing acknowledgements
 * below retransmissions, though doing so would risk missing an
 * acknowledgement received between a ENOACK sendDone and the next
 * transmission.  Besides, the current state machine works, and we
 * probably should be using tkn154 anyway.
 */

generic configuration Rf1aAckC () {
  provides {
    interface Send;
    interface Receive;
    interface PacketAcknowledgements;
  }
  uses {
    interface Send as SubSend;
    interface Receive as SubReceive;
    interface Send as AckSend;
    interface Receive as AckReceive;
    interface Rf1aPacket;
    interface Rf1aPhysicalMetadata;
  }
} implementation {
  components new Rf1aAckP();
  Send = Rf1aAckP.Send;
  Receive = Rf1aAckP;
  PacketAcknowledgements = Rf1aAckP;
  SubSend = Rf1aAckP.SubSend;
  SubReceive = Rf1aAckP.SubReceive;
  AckSend = Rf1aAckP.AckSend;
  AckReceive = Rf1aAckP.AckReceive;
  Rf1aPacket = Rf1aAckP;
  Rf1aPhysicalMetadata = Rf1aAckP;

  /* NB: Can't use AlarmMultiplexC here until it's been made robust in
   * the face of asynchronous uncoordinated users.
   */
  components new Alarm32khz16C();
  Rf1aAckP.AckWaitAlarm -> Alarm32khz16C;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
