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
 * TinyOS network stack for IEEE154 communication on an RF1A radio.
 *
 * This is a demonstration stack; applications may choose to use
 * another with additional features such as low-power listening.
 *
 * Stack structure:
 * - Ieee154 support
 * - TinyOS/Physical bridge
 * - Rf1a physical layer
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

configuration Rf1aIeee154MessageC {
  provides {
    interface SplitControl;

    interface Ieee154Send;
    interface Receive as Ieee154Receive;

    interface Packet;
    interface Ieee154Packet;

    interface MessageLqi;
    interface MessageRssi;

    interface PacketAcknowledgements; /* @TODO@ implement */
    interface LowPowerListening;
    interface Resource;

    interface HplMsp430Rf1aIf;
    interface Rf1aPacket;
    interface Rf1aPhysical;
    interface Rf1aPhysicalMetadata;
    interface Rf1aStatus;
  }
  uses {
    interface Rf1aConfigure;
  }
} implementation {

  /* Packet architecture: The Rf1aIeee154PacketC component provides
   * the core packet layout.
   */
  components new Rf1aIeee154PacketC() as PacketC;
  Packet = PacketC;
  Ieee154Packet = PacketC;
  MessageLqi = PacketC;
  MessageRssi = PacketC;

  /* Stack architecture: A module that supports the Ieee154-relevant
   * interfaces is laid on top of a TinyOS/physical bridge which uses
   * an Rf1a physical layer.
   */
  components new Rf1aPhysicalC() as PhysicalC;
  Resource = PhysicalC;
  HplMsp430Rf1aIf = PhysicalC;
  Rf1aPhysical = PhysicalC;
  Rf1aPhysicalMetadata = PhysicalC;
  Rf1aStatus = PhysicalC;
  Rf1aConfigure = PhysicalC;
  PacketC.Rf1aPhysicalMetadata -> PhysicalC;

  components new Rf1aTinyOsPhysicalC() as TinyOsPhysicalC;
  SplitControl = TinyOsPhysicalC;
  TinyOsPhysicalC.Resource -> PhysicalC;
  TinyOsPhysicalC.Rf1aPhysical -> PhysicalC;
  TinyOsPhysicalC.Rf1aPhysicalMetadata -> PhysicalC;
  TinyOsPhysicalC.Packet -> PacketC;
  TinyOsPhysicalC.Rf1aPacket -> PacketC;
  Rf1aPacket = PacketC;

  components new Rf1aAckC() as AckC;
  AckC.SubSend -> TinyOsPhysicalC.Send[IEEE154_TYPE_DATA];
  AckC.SubReceive -> TinyOsPhysicalC.Receive[IEEE154_TYPE_DATA];
  AckC.AckSend -> TinyOsPhysicalC.Send[IEEE154_TYPE_ACK];
  AckC.AckReceive -> TinyOsPhysicalC.Receive[IEEE154_TYPE_ACK];
  AckC.Rf1aPacket -> PacketC;
  AckC.Rf1aPhysicalMetadata -> PhysicalC;
  PacketAcknowledgements = AckC;

  components Rf1aIeee154MessageP as MsgP;
  MsgP.Packet -> PacketC;
  MsgP.Rf1aPacket -> PacketC;
  MsgP.Ieee154Packet -> PacketC;
  MsgP.SubSend -> AckC.Send;
  MsgP.SubReceive -> AckC.Receive;
  Ieee154Send = MsgP;

#if 0
  /* This would filter out any messages with a DSN in the
   * recently-received queue.  Since the DSN derives from RandomC, and
   * the standard RandomC resets to the same starting point each time
   * the board is restarted, when it's enabled the link layer will
   * drop packets sent from a node if it's rebooted before sending
   * enough traffic to flush the cache.
   *
   * Since the only reason to use this is when using link-layer
   * retransmissions, and we're not, it's now disabled.
   */
  components new UniqueReceiveC();
  UniqueReceiveC.SubReceive -> MsgP.Ieee154Receive;
  Ieee154Receive = UniqueReceiveC.Receive;
#else
  Ieee154Receive = MsgP.Ieee154Receive;
#endif

  components StubLowPowerListeningC;
  LowPowerListening = StubLowPowerListeningC;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
