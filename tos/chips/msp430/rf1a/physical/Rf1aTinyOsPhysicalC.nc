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
 * Bridge an Rf1aPhysical implementation and a network stack that uses
 * standard TinyOS low-level Send and Receive interfaces.
 *
 * This leverages the assumption that the underlying physical radio
 * uses an 802.15.4 stack, and provides interfaces that are
 * parameterized on the frame type.  By doing this we can assume that
 * the parameters involving IEEE154_TYPE_DATA are full message_t
 * structures including the metadata section at a fixed position into
 * the buffer, while those for other frame types may be just large
 * enough to hold the over-the-air payload.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

generic configuration Rf1aTinyOsPhysicalC() {
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

  components new Rf1aTinyOsPhysicalP();
  SplitControl = Rf1aTinyOsPhysicalP;
  Send = Rf1aTinyOsPhysicalP.Send;
  Receive = Rf1aTinyOsPhysicalP;
  Resource = Rf1aTinyOsPhysicalP;
  Rf1aPhysical = Rf1aTinyOsPhysicalP;
  Rf1aPhysicalMetadata = Rf1aTinyOsPhysicalP;
  Packet = Rf1aTinyOsPhysicalP;
  Rf1aPacket = Rf1aTinyOsPhysicalP;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
