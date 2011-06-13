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

#include <limits.h>
#include "Rf1aRadioPower.h"

/** Implement PATABLE and RX attenuation configuration.
 *
 * @note The PATABLE register on the RF1A is an eight-byte vector
 * accessed through a single address.  There is an internal index
 * counter that updates on each access.  Accessing a non-PATABLE
 * register after each PATABLE operation resets this index.  If you
 * choose to access the PATABLE register yourself elsewhere and do not
 * follow this practice, this module may not operate correctly.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

generic module Rf1aRadioPowerC () {
  uses {
    interface HplMsp430Rf1aIf as Rf1aIf;
    interface Rf1aPhysicalIntrospect;
  }
  provides {
    interface Rf1aRadioPower;
  }
} implementation {

  const rf1a_patable_t _patables[] = {
    RF1A_TX_PATABLE_SETTINGS_INIT
  };
  const int8_t _pa_levels[] = RF1A_TX_PATABLE_LEVELS_INIT;
  enum {
    PATABLE_LEN = 8,
    HzPerMHz = 1000000UL,
    PATABLE_COUNT = sizeof(_patables) / sizeof(*_patables),
    NUM_RF1A_TX_POWER = (RF1A_MAX_TX_POWER_INDEX - RF1A_MIN_TX_POWER_INDEX + 1),
  };

  const rf1a_patable_t* _findBestSettingsTable () {
    int freq_MHz = (call Rf1aPhysicalIntrospect.frequencyChannel_Hz()) / HzPerMHz;
    const rf1a_patable_t* best = _patables;
    int pi = 0;
    while (++pi < PATABLE_COUNT) {
      const rf1a_patable_t* pp = _patables + pi;
      if (abs(freq_MHz - pp->freq_MHz) < abs(freq_MHz - best->freq_MHz)) {
        best = pp;
      }
    }
    return best;
  }

  command void Rf1aRadioPower.setTxPower_reg (uint8_t reg) {
    call Rf1aIf.writeRegister(PATABLE, reg);
    /* Reset internal PATABLE idx by issuing non-PATABLE
     * instruction */
    (void)call Rf1aIf.readRegister(PARTNUM);
  }

  int _setTxPower_idx (const rf1a_patable_t* pp,
                       uint8_t idx) {
    call Rf1aRadioPower.setTxPower_reg(pp->patable[idx]);
    return _pa_levels[idx];
  }

  command int Rf1aRadioPower.setTxPower_idx (uint8_t idx) {
    if ((RF1A_MIN_TX_POWER_INDEX > idx) || (RF1A_MAX_TX_POWER_INDEX < idx)) {
      return INT_MAX;
    }
    return _setTxPower_idx(_findBestSettingsTable(), idx);
  }

  command int Rf1aRadioPower.setTxPower_dBm (int dbm) {
    const rf1a_patable_t* pp = _findBestSettingsTable();
    int best = 0;
    int i;

    for (i = 1; i < NUM_RF1A_TX_POWER; ++i) {
      if (abs(_pa_levels[i] - dbm) < abs(_pa_levels[best] - dbm)) {
        best = i;
      }
    }
    return _setTxPower_idx(pp, best);
  }

  command uint8_t Rf1aRadioPower.getTxPower_reg () {
    uint8_t rv;

    rv = call Rf1aIf.readRegister(PATABLE);
    /* Reset internal PATABLE idx by issuing non-PATABLE
     * instruction */
    (void)call Rf1aIf.readRegister(PARTNUM);
    return rv;
  }

  enum {
    /** Scale multiplier for CLOSE_IN_RX */
    RxAttenPerUnit_dBm = 6,
    /** Maximum value of CLOSE_IN_RX */
    RxAttenMax_reg = 3,
    /** Mask off all of FIFOTHR except bits 5:4 which hold CLOSE_IN_RX */
    RxAttenRegMask = 0xCF,
    /** Shift to place CLOSE_IN_RX in correct position */
    RxAttenRegShift = 4,
  };

  command int Rf1aRadioPower.setRxAttenuation_dBm (int dbm) {
    uint8_t atten_reg = 0;
    if (0 < dbm) {
      /* Round to nearest multiple of RxAttenPerUnit_dBm */
      atten_reg = (dbm + (RxAttenPerUnit_dBm / 2)) / RxAttenPerUnit_dBm;
      if (RxAttenMax_reg < atten_reg) {
        atten_reg = RxAttenMax_reg;
      }
    }
    (void)call Rf1aIf.writeRegister(FIFOTHR, (atten_reg << RxAttenRegShift) | (RxAttenRegMask & call Rf1aIf.readRegister(FIFOTHR)));
    return atten_reg * RxAttenPerUnit_dBm;
  }

  command int Rf1aRadioPower.getRxAttenuation_dBm () {
    return RxAttenPerUnit_dBm * (((~ RxAttenRegMask) & (call Rf1aIf.readRegister(FIFOTHR))) >> RxAttenRegShift);
  }
}
