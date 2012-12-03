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

/** Implementation of Ieee154 interfaces on RF1A.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module Rf1aIeee154MessageP {
  provides {
    interface Ieee154Send;
    interface Receive as Ieee154Receive;
  }
  uses {
    interface Packet;
    interface Rf1aPacket;
    interface Ieee154Packet;
    interface Send as SubSend;
    interface Receive as SubReceive;
  }
}
implementation {
  command error_t Ieee154Send.send(ieee154_saddr_t addr, message_t* msg, uint8_t len) {
    call Rf1aPacket.configureAsData(msg);
    call Ieee154Packet.setPan(msg, call Ieee154Packet.localPan());
    call Ieee154Packet.setSource(msg, call Ieee154Packet.address());
    call Ieee154Packet.setDestination(msg, addr);
    return call SubSend.send(msg, len);
  }

  event void SubSend.sendDone(message_t* msg, error_t error) { signal Ieee154Send.sendDone(msg, error); }

  command error_t Ieee154Send.cancel(message_t* msg) { return FAIL; }

  default event void Ieee154Send.sendDone(message_t* msg, error_t error) { }

  command uint8_t Ieee154Send.maxPayloadLength() { return call Packet.maxPayloadLength(); }

  command void* Ieee154Send.getPayload(message_t* msg, uint8_t len) { return call Packet.getPayload(msg, len); }

  event message_t* SubReceive.receive(message_t* msg, void* payload, uint8_t len) {
    if (call Ieee154Packet.isForMe(msg)) {
      return signal Ieee154Receive.receive(msg, payload, len);
    }
    return msg;
  }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
