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

#ifndef _Rf1aRadioPower_h_
#define _Rf1aRadioPower_h_

/** Infrastructure to support selecting PATABLE register values based
 * on carrier frequency and desired output power level in dBm.
 *
 * Note: That there are eight power levels in the default table is an
 * artifact of the facts that the RF1A PATABLE has eight entries and
 * the suggested values in the data sheet correspond to eight entries
 * at specified levels.  The number of entries in the tables used by
 * Rf1aRadioPowerC to map between dBm and power register values is
 * independent of this.  Feel free to redefine the
 * RF1A_MIN_TX_POWER_INDEX and RF1A_MAX_TX_POWER_INDEX extrema to
 * allow more or fewer entries in each table.  Make sure you also
 * redefine RF1A_TX_PATABLE_SETTINGS_INIT and
 * RF1A_TX_PATABLE_LEVELS_INIT.
 *
 * SmartRF Studio may suggest other PATABLE values.
 */

#ifndef RF1A_MIN_TX_POWER_INDEX
#define RF1A_MIN_TX_POWER_INDEX 0
#endif /* RF1A_MIN_TX_POWER_INDEX */

#ifndef RF1A_MAX_TX_POWER_INDEX
#define RF1A_MAX_TX_POWER_INDEX 7
#endif /* RF1A_MAX_TX_POWER_INDEX */

/** Structure used to hold PATABLE configuration data. */
typedef struct rf1a_patable_t {
  /** A frequency at which the given patable settings apply */
  int freq_MHz;
  /** A table of power settings mapping register values to to the
   * RF1A_TX_PATABLE_POWER dBm values at the specified frequency */
  uint8_t patable[RF1A_MAX_TX_POWER_INDEX + 1 - RF1A_MIN_TX_POWER_INDEX];
} rf1a_patable_t;

#ifndef RF1A_TX_PATABLE_SETTINGS_INIT

/** Sequence of rf1a_patable_t entries used in Rf1aRadioPowerC to find
 * the best PATABLE settings for a given carrier frequency, and the
 * best power register value for a given power level in dBm. */
#define RF1A_TX_PATABLE_SETTINGS_INIT \
    { 315, { 0x12, 0x0d, 0x1c, 0x34, 0x51, 0x85, 0xcb, 0xc2 } }, \
    { 433, { 0x12, 0x0e, 0x1d, 0x34, 0x60, 0x84, 0xc8, 0xc0 } }, \
    { 868, { 0x03, 0x0f, 0x1e, 0x27, 0x60, 0x81, 0xcb, 0xc2 } }, \
    { 915, { 0x03, 0x0e, 0x1e, 0x27, 0x8e, 0xcd, 0xc7, 0xc0 } }

#endif /* RF1A_TX_PATABLE_SETTINGS_INIT */

#ifndef RF1A_TX_PATABLE_LEVELS_INIT
#define RF1A_TX_PATABLE_LEVELS_INIT { -30, -20, -15, -10, 0, 5, 7, 10 }
#endif /* RF1A_TX_PATABLE_LEVELS_INIT */

#endif /* _Rf1aRadioPower_h_ */
