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

/**
 * TinyOS network stack for ActiveMessage communication on an RF1A radio.
 *
 * This is a demonstration stack; applications may choose to use
 * another with additional features such as low-power listening.
 *
 * Stack structure:
 * - ActiveMessage support
 * - TinyOS/Physical bridge
 * - Rf1a physical layer
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

configuration Rf1aActiveMessageC {
  provides {
    interface SplitControl;
    interface AMSend[am_id_t id];
    interface SendNotifier[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];
    interface Packet;
    interface AMPacket;
    interface Resource;
    interface PacketAcknowledgements;

    interface HplMsp430Rf1aIf;
    interface Rf1aPacket;
    interface Rf1aPhysical;
    interface Rf1aStatus;
  }
}
implementation {
  /* Packet architecture: The Rf1aIeee154PacketC component provides
   * the core packet layout.  Active message support is inserted into
   * the payload of that structure. */
  components Rf1aAMPacketC as PacketC;
  Packet = PacketC;
  AMPacket = PacketC;

  components new Rf1aIeee154PacketC() as PhyPacketC;
  PacketC.Ieee154Packet -> PhyPacketC;
  PacketC.SubPacket -> PhyPacketC;
  PacketC.Rf1aPacket -> PhyPacketC;
  Rf1aPacket = PhyPacketC;

  /* Get support for identifying the node's address.  Implementation
   * derives from underlying 802.15.4 address. */
  components Ieee154AMAddressC;
  PacketC.ActiveMessageAddress -> Ieee154AMAddressC;

  /* Stack architecture: A module that supports the
   * ActiveMessage-relevant interfaces is laid on top of a
   * TinyOS/physical bridge which uses an Rf1a physical layer. */
  components new Rf1aPhysicalC() as PhysicalC;
  Resource = PhysicalC;
  HplMsp430Rf1aIf = PhysicalC;
  Rf1aPhysical = PhysicalC;
  Rf1aStatus = PhysicalC;
  PhyPacketC.Rf1aPhysicalMetadata -> PhysicalC;

  components new Rf1aTinyOsPhysicalC() as TinyOsPhysicalC;
  SplitControl = TinyOsPhysicalC;
  TinyOsPhysicalC.Resource -> PhysicalC;
  TinyOsPhysicalC.Rf1aPhysical -> PhysicalC;
  TinyOsPhysicalC.Rf1aPhysicalMetadata -> PhysicalC;
  TinyOsPhysicalC.Packet -> PacketC;
  TinyOsPhysicalC.Rf1aPacket -> PhyPacketC;

  components new Rf1aAckC() as AckC;
  AckC.SubSend -> TinyOsPhysicalC.Send[IEEE154_TYPE_DATA];
  AckC.SubReceive -> TinyOsPhysicalC.Receive[IEEE154_TYPE_DATA];
  AckC.AckSend -> TinyOsPhysicalC.Send[IEEE154_TYPE_ACK];
  AckC.AckReceive -> TinyOsPhysicalC.Receive[IEEE154_TYPE_ACK];
  AckC.Rf1aPacket -> PhyPacketC;
  AckC.Rf1aPhysicalMetadata -> PhysicalC;
  PacketAcknowledgements = AckC;

  components new UniqueReceiveC();
  UniqueReceiveC.SubReceive -> AckC.Receive;

  components Rf1aActiveMessageP as AM;
  AMSend = AM;
  SendNotifier = AM;
  Receive = AM.Receive;
  Snoop = AM.Snoop;
  AM.Rf1aPacket -> PhyPacketC;
  AM.Ieee154Packet -> PhyPacketC;
  AM.Packet -> PacketC;
  AM.AMPacket -> PacketC;
  AM.SubSend -> AckC.Send;
  AM.SubReceive -> UniqueReceiveC.Receive;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
