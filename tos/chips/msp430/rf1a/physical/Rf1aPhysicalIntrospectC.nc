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

/** Implement the physical introspection interface for a given physical radio.
 *
 * All calculations in this module are straight out of the peripheral
 * register definitions in the SLAU259 document.
 */

generic module Rf1aPhysicalIntrospectC () {
  uses {
    interface HplMsp430Rf1aIf as Rf1aIf;
  }
  provides {
    interface Rf1aPhysicalIntrospect;
  }
} implementation {

#ifndef REPLICATE_BUG
  /* 20100830 GCC optimizer bug with this code.  If the frequency is
   * calculated by shifting its individual components, the resulting
   * 64-bit integer is not correctly shifted back.  Where
   * FREQ=0x22b13b, the carrier frequency retains the 0xb13b bits in
   * the upper half of the 32-bit result, as well as in the lower
   * half.
   */
#define REPLICATE_BUG 0
#endif

  uint32_t _f_xosc_Hz =
#if REPLICATE_BUG
#define BASE 1
  1UL << BASE
#else
#define BASE 16
  26000000UL
#endif
  ;

  command uint32_t Rf1aPhysicalIntrospect.getFrequencyXOSC_Hz () { return _f_xosc_Hz; }
  command void Rf1aPhysicalIntrospect.setFrequencyXOSC_Hz (uint32_t f_xosc_Hz) { _f_xosc_Hz = f_xosc_Hz; }

  command uint32_t Rf1aPhysicalIntrospect.frequencyCarrier_Hz () {
    uint64_t f_xosc_ull = _f_xosc_Hz;
#if ! REPLICATE_BUG
    volatile 
#endif
      uint32_t freq = ((((uint32_t)call Rf1aIf.readRegister(FREQ2)) << 16)
                       | (((uint32_t)call Rf1aIf.readRegister(FREQ1)) << 8)
                       | ((uint32_t)call Rf1aIf.readRegister(FREQ0)));
    return (uint32_t)((f_xosc_ull * freq) >> BASE);
  }

  command uint32_t Rf1aPhysicalIntrospect.channelDeltaFrequency_Hz () {
    uint64_t f_xosc_ull = _f_xosc_Hz;
    uint16_t chanspc_e = 0x03 & call Rf1aIf.readRegister(MDMCFG1);
    uint16_t chanspc_m = call Rf1aIf.readRegister(MDMCFG0);

    return (uint32_t)((f_xosc_ull * (256UL + chanspc_m) * (1UL << chanspc_e)) >> (2 + BASE));
  }

  command uint32_t Rf1aPhysicalIntrospect.frequencyChannel_Hz () {
    uint32_t f_hz = call Rf1aPhysicalIntrospect.frequencyCarrier_Hz();
    uint32_t df_hz = call Rf1aPhysicalIntrospect.channelDeltaFrequency_Hz();
    uint16_t channr = call Rf1aIf.readRegister(
#if REPLICATE_BUG
      /* For bug replication, use a register that returns zero, thus
       * discarding the channel delta frequency component.
       */
      PARTNUM
#else
      CHANNR
#endif
);

    return f_hz + channr * df_hz;
  }

  command uint32_t Rf1aPhysicalIntrospect.frequencyIf_Hz () {
    uint8_t freq_if = 0x0F & call Rf1aIf.readRegister(FSCTRL1);
    return (_f_xosc_Hz * freq_if) >> 10;
  }

  command uint32_t Rf1aPhysicalIntrospect.bandwidthChannel_Hz () {
    uint8_t mdmcfg4 = call Rf1aIf.readRegister(MDMCFG4);
    uint8_t chanbw_e = 0x03 & (mdmcfg4 >> 6);
    uint8_t chanbw_m = 0x03 & (mdmcfg4 >> 4);
    return _f_xosc_Hz / (8 * (4 + chanbw_m) * (1UL << chanbw_e));
  }

  command uint32_t Rf1aPhysicalIntrospect.dataRate_Bps () {
    uint8_t drate_e = 0x0F & call Rf1aIf.readRegister(MDMCFG4);
    uint8_t drate_m = call Rf1aIf.readRegister(MDMCFG3);
    uint32_t r_data_baud;
    uint32_t r_data_Bps;
    uint64_t t_ull = _f_xosc_Hz;

    t_ull <<= drate_e;
    t_ull *= (256 + drate_m);
    r_data_baud = (uint32_t)(t_ull >> 28);
    r_data_Bps = r_data_baud / 8;
    if (0x08 & call Rf1aIf.readRegister(MDMCFG2)) {
      r_data_Bps /= 2;
    }
    return r_data_Bps;
  }
}
