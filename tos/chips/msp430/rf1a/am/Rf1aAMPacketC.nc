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

/** RF1A-specific support for ActiveMessage packets.
 *
 * This component inserts into the payload a two-octet Not-A-LoWPAN
 * header to hold a TinyOS ActiveMessage type id.  It also provides
 * the necessary interfaces to re-use transport-agnostic ActiveMessage
 * components.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

configuration Rf1aAMPacketC {
  provides {
    interface Packet;
    interface AMPacket;
  }
  uses {
    interface Packet as SubPacket;
    interface Rf1aPacket;
    interface Ieee154Packet;
    interface ActiveMessageAddress;
  }
} implementation {
  components Rf1aAMPacketP as PacketP;
  Packet = PacketP;
  AMPacket = PacketP;
  SubPacket = PacketP;
  Rf1aPacket = PacketP;
  Ieee154Packet = PacketP;
  ActiveMessageAddress = PacketP;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
