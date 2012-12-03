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

/** Operations relevant to metadata on an RF1A physical interface.
 *
 * This interface is coupled with Rf1aPhysical, in that it is the
 * module that implements Rf1aPhysical that provides the metadata that
 * is stored through this interface.  It is provided separately
 * because access to the metadata is required at levels of the stack
 * (such as acknowledgement processing) than have no need for full
 * Rf1aPhysical capabilities.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

#include "Rf1aPacket.h"

interface Rf1aPhysicalMetadata {

  /** Store current metadata.
   *
   * This updates those metadata fields specific to the physical
   * layer, such as rssi and lqi, to the values associated with the
   * most recently received packet.  Fields unrelated to the physical
   * layer, such as the reconstructed packet length, are left
   * untouched.
   *
   * To ensure the captured metadata is relevant, this function should
   * be invoked ASAP after the packet reception is completed by the
   * radio, e.g. during the receiveDone event.
   *
   * Note that the values stored are in raw radio format.  Other
   * methods in the Rf1aPhysicalMetadata interface should be used to
   * extract relevant information.
   *
   * @param metadatap Pointer to the metadata packet into which the
   * relevant information should be stored
   */
  async command void store (rf1a_metadata_t* metadatap);

  /** Get the received signal strength indicator for a given packet.
   *
   * This is the RSSI provided by the radio as locked at the point the
   * sync word was demodulated for the received packet.  The value is
   * in dBm.
   */
  async command int rssi (const rf1a_metadata_t* metadatap);

  /** Get link quality indicator for a given packet.
   *
   * This is the radio measure of distance between ideal and received
   * signal over the 64 symbols following the sync word of the
   * received packet.
   */
  async command int lqi (const rf1a_metadata_t* metadatap);

  /** Indicate whether the hardware CRC passed for the received packet. */
  async command bool crcPassed (const rf1a_metadata_t* metadatap);
}
