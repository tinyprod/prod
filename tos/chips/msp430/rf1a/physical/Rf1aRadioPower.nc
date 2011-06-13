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

/** Control the transmission power and receiver attenuation of an RF1A
 * radio module.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

interface Rf1aRadioPower {

  /** Set the transmit power register.
   *
   * This function assumes that a valid value is obtained from
   * somewhere.  It is not possible to determine the corresponding
   * dBm.  It further assumes that the radio is configured with
   * FREND0.PO_POWER set to zero, indicating a constant power used
   * throughout transmission.
   *
   * @note Power register values from 0x61 through 0x6F are not
   * allowed on the CC430/RF1A.
   */
  command void setTxPower_reg (uint8_t reg);

  /** Retrieve the value of the transport power register. */
  command uint8_t getTxPower_reg ();

  /** Set the transmit power to the specified level.
   *
   * @param idx a value between RF1A_MIN_TX_POWER_INDEX and
   * RF1A_MAX_TX_POWER_INDEX
   *
   * @return the corresponding power level, in dBm, or MAXINT if idx
   * is not a valid value.
   */
  command int setTxPower_idx (uint8_t idx);

  /** Set the transmit power to the closest table value for the given dbm.
   *
   * This function uses the carrier frequency to select from a
   * chip-specific set of PATABLE settings, then programs the radio to
   * use the corresponding setting.  
   *
   * @return the selected transmission power, in dBm
   *
   * @note The vendor-provided tables for the CC430 cover transmission
   * power levels of -30, -20, -15, -10, 0, 5, 7, and 10 dBm.  No
   * interpolation is done between vendor-provided points in the
   * table.
   */
  command int setTxPower_dBm (int dbm);

  /** Set the receive attenuation in dBm to the closest supported value.
   *
   * See also SWRA147, "Close-in Reception with CC1101".
   *
   * @return The resulting rx attenuation level.
   *
   * @note The CC430 supports receive attenuation levels of 0, 6, 12,
   * and 18 dB.
   */
  command int setRxAttenuation_dBm (int dbm);

  /** Retrieve the current receiver attenuation.
   *
   * @return RX attenuation in dBm.
   */
  command int getRxAttenuation_dBm ();
}
