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

/** Implementation of ActiveMessage interfaces on RF1A.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module Rf1aActiveMessageP {
  provides {
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];
    interface SendNotifier[am_id_t id];
  }
  uses {
    interface Rf1aPacket;
    interface Ieee154Packet;
    interface Packet;
    interface AMPacket;
    interface Send as SubSend;
    interface Receive as SubReceive;
  }
}
implementation {
  /** Convenience typedef denoting the structure used as a header in
   * this packet layout. */
  typedef rf1a_nalp_am_t layer_header_t;

  command error_t AMSend.send[am_id_t id](am_addr_t addr,
                                          message_t* msg,
                                          uint8_t len) {
    call Rf1aPacket.configureAsData(msg);
    call AMPacket.setSource(msg, call AMPacket.address());
    call Ieee154Packet.setPan(msg, call Ieee154Packet.localPan());
    call AMPacket.setDestination(msg, addr);
    call AMPacket.setType(msg, id);
    signal SendNotifier.aboutToSend[id](addr, msg);
    // Account for layer header in payload length
    return call SubSend.send(msg, len + sizeof(layer_header_t));
  }

  command uint8_t AMSend.maxPayloadLength[am_id_t id]() {
    return call Packet.maxPayloadLength();
  }

  command void* AMSend.getPayload[am_id_t id](message_t* m, uint8_t len) {
    return call Packet.getPayload(m, len);
  }

  command error_t AMSend.cancel[am_id_t id](message_t* msg) {
    return call SubSend.cancel(msg);
  }

  event void SubSend.sendDone(message_t* msg, error_t error) {
    signal AMSend.sendDone[call AMPacket.type(msg)](msg, error);
  }

  event message_t* SubReceive.receive(message_t* msg, void* payload_, uint8_t len) {
    uint8_t* payload = (uint8_t*)payload_ + sizeof(layer_header_t);
    len -= sizeof(layer_header_t);
    if (call AMPacket.isForMe(msg)) {
      return signal Receive.receive[call AMPacket.type(msg)](msg, payload, len);
    }
    return signal Snoop.receive[call AMPacket.type(msg)](msg, payload, len);
  }

  default event message_t* Receive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) { return msg; }
  default event message_t* Snoop.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) { return msg; }
  default event void SendNotifier.aboutToSend[am_id_t amId](am_addr_t addr, message_t *msg) { }
  default event void AMSend.sendDone[am_id_t amId](message_t* msg, error_t error) { }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
