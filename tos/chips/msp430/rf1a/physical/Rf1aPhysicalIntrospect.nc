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

/** Facilities to query the internal configuration of the radio and
 * extract relevant information converted to units that are meaningful
 * to (certain) humans.  Mainly used by normal applications to confirm
 * that the underlying physical configuration of the radio is what
 * they intended to use.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

interface Rf1aPhysicalIntrospect {
  /** Inspect the configured frequency of the radio XOSC clock.
   *
   * f_XOSC is used to calculate the frequencies of various radio
   * characteristics.  The default value for this is 26*10^6 Hz,
   * and it's unlikely to be something else.
   */
  command uint32_t getFrequencyXOSC_Hz ();

  /** Set the configured frequency of the radio XOSC clock.
   *
   * You only need to use this if you have a board with XOSC that is
   * not 26MHz.
   */
  command void setFrequencyXOSC_Hz (uint32_t f_xosc_Hz);

  /** Calculate the carrier frequency, in Hz.
   *
   * This is the base frequency of the radio.  It is not what the
   * radio transmits/receives at.  For that you want the channel
   * frequency.
   */
  command uint32_t frequencyCarrier_Hz ();

  /** Calculate the delta frequency between channels, in Hz. */
  command uint32_t channelDeltaFrequency_Hz ();

  /** Calculate the channel frequency, in Hz.
   *
   * This is the carrier frequency plus the channel number times the
   * channel delta frequency.  It's the value you need if you want to
   * know what frequency the radio receives/transmits.
   */
  command uint32_t frequencyChannel_Hz ();

  /** Calculate the intermediate frequency, in Hz */
  command uint32_t frequencyIf_Hz ();

  /** Calculate the channel bandwidth, in Hz. */
  command uint32_t bandwidthChannel_Hz ();

  /** Calculate the transmission data rate, in bytes per second.
   *
   * This derives from the baud rate, assuming eight bits per byte and
   * adjusted for Manchester encoding if that is enabled.
   */
  command uint32_t dataRate_Bps ();
}
