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

/** Implementation of ActiveMessage-relevant packet management
 * interfaces for RF1A.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module Rf1aAMPacketP {
  provides {
    interface Packet;
    interface AMPacket;
  }
  uses {
    interface Packet as SubPacket;
    interface Ieee154Packet;
    interface Rf1aPacket;
    interface ActiveMessageAddress;
  }
} implementation {

  /** Convenience typedef denoting the structure used as a header in
   * this packet layout. */

  typedef rf1a_nalp_am_t layer_header_t;

  /** Get a cast pointer to the extension header introduced at this layer */
  layer_header_t* layerHeader (message_t* msg) { return (layer_header_t*) call SubPacket.getPayload(msg, 0); }

  command void Packet.clear(message_t* msg) {
    layer_header_t* lhp;

    /* Execute the normal clear process */
    call SubPacket.clear(msg);

    /* Store the dispatch code */
    lhp = layerHeader(msg);
    lhp->nalp_tinyos = LOWPAN_NALP_TINYOS;
  }

  /** Adjust the payload to account for the layer header.  There is no
   * footer at this layer.
   */

  command uint8_t Packet.maxPayloadLength() { return call SubPacket.maxPayloadLength() - sizeof(layer_header_t); }
  command void Packet.setPayloadLength(message_t* msg, uint8_t len) { call SubPacket.setPayloadLength(msg, len + sizeof(layer_header_t)); }
  command uint8_t Packet.payloadLength(message_t* msg) { return call SubPacket.payloadLength(msg) - sizeof(layer_header_t); }
  command void* Packet.getPayload(message_t* msg, uint8_t len) { return (void*)(1 + layerHeader(msg)); }

  command am_addr_t AMPacket.address() { return call ActiveMessageAddress.amAddress(); }
  command am_addr_t AMPacket.destination(message_t* amsg) { return call Ieee154Packet.destination(amsg); }
  command am_addr_t AMPacket.source(message_t* amsg) { return call Ieee154Packet.source(amsg); }
  command void AMPacket.setDestination(message_t* amsg, am_addr_t addr) { call Ieee154Packet.setDestination(amsg, addr); }
  command void AMPacket.setSource(message_t* amsg, am_addr_t addr) { call Ieee154Packet.setSource(amsg, addr); }

  command bool AMPacket.isForMe(message_t* amsg) {
    return (call AMPacket.destination(amsg) == call AMPacket.address() ||
            call AMPacket.destination(amsg) == AM_BROADCAST_ADDR);
  }

  command am_id_t AMPacket.type(message_t* amsg) {
    layer_header_t* lhp = layerHeader(amsg);
    return lhp->am_type;
  }

  command void AMPacket.setType(message_t* amsg, am_id_t t) {
    layer_header_t* lhp = layerHeader(amsg);

    lhp->nalp_tinyos = LOWPAN_NALP_TINYOS;
    lhp->am_type = t;
  }

  /** Store the active message group in the 802.15.4 PAN_ID field */
  command am_group_t AMPacket.group(message_t* amsg) { return call Ieee154Packet.pan(amsg); } 
  command void AMPacket.setGroup(message_t* amsg, am_group_t grp) { call Ieee154Packet.setPan(amsg, grp); }
  command am_group_t AMPacket.localGroup() { return call Ieee154Packet.localPan(); }

  async event void ActiveMessageAddress.changed() { }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
