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
#include "message.h"

/** Extract packet information required to transmit a message on an
 * RF1A radio.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

interface Rf1aPacket {

  /** Get a pointer to the metadata for the given message.
   *
   * This is a convenience function, and should simply return a cast
   * pointer to the message_t metadata section.
   */
  async command rf1a_metadata_t* metadata (message_t* msg);

  /** Configure the IEEE 802.15.4 header to mark this as a data packet.
   *
   * This sets the DSN, as well as those FCF fields that must be
   * consistent with the structure used for rf1a_ieee154_t.  It
   * preserves those FCF fields that might be externally configured
   * (Security Enabled, Frame Pending, and Acknowledgment Requested).
   * It should be invoked somewhere in the stack exactly once per
   * high-level TinyOS send operation.
   */
  async command void configureAsData (message_t* msg);

  /** Get the received signal strength indicator for a given packet.
   *
   * Forwards to Rf1aPhysicalMetadata.rssi().  For sent packets, the
   * value is provided from the acknowledgment, and is undefined if
   * no acknowledgment was received.
   */
  async command int rssi (const message_t* msg);

  /** Get link quality indicator for a given packet.
   *
   * Forwards to Rf1aPhysicalMetadata.lqi().  For sent packets, the
   * value is provided from the acknowledgment, and is undefined if
   * no acknowledgment was received.
   */
  async command int lqi (const message_t* msg);

  /** Indicate whether the hardware CRC passed for the received
   * packet.
   *
   * Forwards to Rf1aPhysicalMetadata.crcPassed().  For sent packets, the
   * value is provided from the acknowledgment, and is FALSE if
   * no acknowledgment was received.
   */
  async command bool crcPassed (const message_t* msg);
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
