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

/** Implementation of core packet management interfaces for RF1A.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */
generic module Rf1aIeee154PacketP () {
  provides {
    interface Init;
    interface Packet;
    interface Ieee154Packet;
    interface Rf1aPacket;
    interface MessageLqi;
    interface MessageRssi;
  }
  uses {
    interface Random;
    interface Rf1aPhysicalMetadata;
    interface Ieee154Address;
  }
} implementation {

  enum {
    /** Mask for header FCF bits that should be left at their
     * caller-provided settings
     */
    FCF_PRESERVE = ( (1 << IEEE154_FCF_SECURITY_ENABLED)
                     | (1 << IEEE154_FCF_FRAME_PENDING)
                     | (1 << IEEE154_FCF_ACK_REQ) ),

    /** Constant FCF subfield settings for any message transmitted
     * through this interface.  This value is constant due to the
     * current choice of a fixed rf1a_ieee154_t structure.
     */
    FCF_FIXED = ( (IEEE154_TYPE_DATA << IEEE154_FCF_FRAME_TYPE)
                  | (IEEE154_ADDR_SHORT << IEEE154_FCF_DEST_ADDR_MODE)
                  | (1 << IEEE154_FCF_INTRAPAN)
                  | (IEEE154_ADDR_SHORT << IEEE154_FCF_SRC_ADDR_MODE) ),
  };

  /** The data sequence number to be used. */
  uint8_t macDSN;

  command error_t Init.init () {
    /* Initialize the DSN */
    macDSN = (uint8_t) call Random.rand16();
    return SUCCESS;
  }

  /** Convenience typedef denoting the structure used as a header in
   * this packet layout.
   */
  typedef rf1a_ieee154_t header_t;

  /** Get a cast pointer to the layer header */
  header_t* header (message_t* msg) { return (header_t*)(msg->data - sizeof(header_t)); }

  /** Convenience typedef denoting the structure used to hold
   * packet-relevant metadata
   */
  typedef rf1a_metadata_t metadata_t;

  /** Get a cast pointer to the packet metadata */
  metadata_t* metadata_ (message_t* msg) { return (rf1a_metadata_t*)msg->metadata; }
  const metadata_t* cmetadata_ (const message_t* msg) { return (const rf1a_metadata_t*)msg->metadata; }

  async command rf1a_metadata_t* Rf1aPacket.metadata (message_t* msg) { return metadata_(msg); }

  async command void Rf1aPacket.configureAsData (message_t* msg) {
    header_t* hp = header(msg);
    metadata_t* mp = metadata_(msg);

    /* Preserve the FCF bits that might be configured through other
     * interfaces.  Override anything else.  But do it first, in case
     * somebody extends Ieee154Packet to be more flexible.
     */
    hp->fcf = (hp->fcf & FCF_PRESERVE) | FCF_FIXED;
    atomic {
      hp->dsn = macDSN++;
    }

    /* Reset the RSSI and LQI fields, allow constant (if "undefined")
     * values to be read back for unacknowledged sent packets
     */
    mp->rssi = mp->lqi = 0;
  }

  inline 
  async command int Rf1aPacket.rssi (const message_t* msg) { return call Rf1aPhysicalMetadata.rssi(cmetadata_(msg)); }

  command int MessageRssi.rssi (const message_t* msg) { return call Rf1aPhysicalMetadata.rssi(cmetadata_(msg)); }

  async command int Rf1aPacket.lqi (const message_t* msg) { return call Rf1aPhysicalMetadata.lqi(cmetadata_(msg)); }

  command int MessageLqi.lqi (const message_t* msg) { return call Rf1aPhysicalMetadata.lqi(cmetadata_(msg)); }

  async command bool Rf1aPacket.crcPassed (const message_t* msg) { return call Rf1aPhysicalMetadata.crcPassed(cmetadata_(msg)); }

  command ieee154_saddr_t Ieee154Packet.address() { return call Ieee154Address.shortAddress(); }

  command ieee154_saddr_t Ieee154Packet.destination(message_t* msg) { return header(msg)->dest; }

  command ieee154_saddr_t Ieee154Packet.source(message_t* msg) { return header(msg)->src; }

  command void Ieee154Packet.setDestination(message_t* msg, ieee154_saddr_t addr) { header(msg)->dest = addr; }

  command void Ieee154Packet.setSource(message_t* msg, ieee154_saddr_t addr) { header(msg)->src = addr; }

  command bool Ieee154Packet.isForMe(message_t* msg) {
    /* IEEE 802.5.4-2006 section 7.5.6.2, reduced: The packet is for
     * me if the destination PAN matches my PAN or the broadcast PAN;
     * and the destination address matches my address or the broadcast
     * address.
     *
     * @TODO@ Until macPromiscuousMode is supported, setting the node
     * panId() to IEEE154_BROADCAST_PAN is used to accept packets from
     * arbitrary PANs.  7.5.6.2 sanctions this only for beacon
     * frames.  The local short address is similarly interpreted.
     */
    ieee154_panid_t dpan = call Ieee154Packet.pan(msg);
    ieee154_saddr_t daddr = call Ieee154Packet.destination(msg);

    return (((call Ieee154Address.panId() == dpan) || (IEEE154_BROADCAST_PAN == dpan) || (IEEE154_BROADCAST_PAN == call Ieee154Address.panId()))
            && ((call Ieee154Address.shortAddress() == daddr) || (IEEE154_BROADCAST_ADDR == daddr) || (IEEE154_BROADCAST_ADDR == call Ieee154Address.shortAddress())));
  }

  command ieee154_panid_t Ieee154Packet.pan(message_t* msg) { return header(msg)->destpan; }

  command void Ieee154Packet.setPan(message_t* msg, ieee154_panid_t grp) { header(msg)->destpan = grp; }

  command ieee154_panid_t Ieee154Packet.localPan() { return call Ieee154Address.panId(); }

  command void Packet.clear(message_t* msg) {
    memset(msg, 0, sizeof(*msg));
  }

  command uint8_t Packet.maxPayloadLength() { return TOSH_DATA_LENGTH; }

  command void Packet.setPayloadLength(message_t* msg, uint8_t len) { metadata_(msg)->payload_length = len + sizeof(header_t); }

  command uint8_t Packet.payloadLength(message_t* msg) { return cmetadata_(msg)->payload_length - sizeof(header_t); }

  command void* Packet.getPayload(message_t* msg, uint8_t len) {
    return ((len + sizeof(header_t)) <= TOSH_DATA_LENGTH) ? (void*)msg->data : 0;
  }

  async event void Ieee154Address.changed () { }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
