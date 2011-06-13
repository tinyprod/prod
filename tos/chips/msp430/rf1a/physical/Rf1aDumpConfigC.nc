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

/** Dump internal radio configuration information to the console for
 * debugging purposes.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module Rf1aDumpConfigC {
  provides {
    interface Rf1aDumpConfig;
  }
} implementation {

  const char* const gdo_signal[] = {
    "RXFIFO>THR",               /* 0 */
    "RXFIFO>THR or EOP",
    "TXFIFO>THR",
    "TXFIFO FULL",
    "RXFIFO OFL",
    "TXFIFO UFL",               /* 5 */
    "SYNC RX/TX",
    "RX CRC OK",
    "PQI>THR",
    "CCA (RSSI<THR)",
    "PLL LOCK",                 /* 10 */
    "SERIAL CLK",
    "SSD OUT",
    "SD OUT",
    "CARRIER SENSE",
    "CRC_OK",                   /* 15 */
    "RESERVED",
    "RESERVED",
    "RESERVED",
    "RESERVED",
    "RESERVED",                 /* 20 */
    "RESERVED",
    "RX_HARD_DATA[1]",
    "RX_HARD_DATA[0]",
    "RESERVED",
    "RESERVED",                 /* 25 */
    "RESERVED",
    "PA PWR DN",
    "LNA PWR DN",
    "RX_SYMBOL_TICK",
    "RSSI_VALID",               /* 30 */
    "RX_TIMEOUT",
    "RESERVED",
    "RESERVED",
    "RESERVED",
    "RESERVED",                 /* 35 */
    "WOR_EVENT0",
    "WOR_EVENT1",
    "RESERVED",
    "CLK_32K",
    "RESERVED",                 /* 40 */
    "RF_RDYn",
    "RESERVED",
    "XOSC_STABLE",
    "RESERVED",
    "GDO0 MAGIC",               /* 45 */
    "TRI-STATE (default)",
    "ZERO",
    "RFCLK/1",
    "RFCLK/1.5",
    "RFCLK/2",                  /* 50 */
    "RFCLK/3",
    "RFCLK/4",
    "RFCLK/6",
    "RFCLK/8",
    "RFCLK/12",                 /* 55 */
    "RFCLK/16",
    "RFCLK/24",
    "RFCLK/32",
    "RFCLK/48",
    "RFCLK/64",                 /* 60 */
    "RFCLK/96",
    "RFCLK/128",
    "RFCLK/192"
  };

  const uint8_t close_in_rx [] = { 0, 6, 12, 18 };
  const uint8_t fifo_thr_tx[] = { 61, 57, 53, 49, 45, 41, 37, 33,
                                  29, 25, 21, 17, 13,  9,  5,  1 };
  const uint8_t fifo_thr_rx[] = {  4,  8, 12, 16, 20, 24, 28, 32,
                                  36, 40, 44, 48, 52, 56, 60, 64 };
  const char* const adr_chk[] = { "None", "Addr, no bcast", "Addr and 0 bcast", "Addr and 0 bcast and 255 bcast" };
  const char* const pkt_format[] = { "Normal", "Sync serial", "Random TX", "Async serial" };
  const char* const length_config[] = { "Fixed PKTLEN", "Variable", "Infinite", "Reserved" };
  const char* const mod_format[] = { "2-FSK", "2-GFSK", "Reserved", "ASK/OOK",
                                     "Reserved", "Reserved", "Reserved", "MSK" };
  const char* const sync_mode[] = { "no sync", "15/16 sync", "16/16 sync", "30/32 sync",
                                    "CS + no sync", "CS + 15/16 sync", "CS + 16/16 sync", "CS + 30/32 sync" };
  const uint8_t num_preamble[] = { 2, 3, 4, 6, 8, 12, 16, 24 };
  const char* const cca_mode[] = { "always", "RSSI<THR", "unless RX" , "RSSI<THR unless RX" };
  const char* const rxtxoff_mode[] = { "IDLE", "FSTXON", "TX", "RX" };
  const char* const fs_autocal[] = { "never", "leave IDLE", "enter IDLE", "4th enter IDLE" };
  const char* const max_lna_gain[] = { "MAX", "MAX-2.6dB", "MAX-6.1dB", "MAX-7.4dB",
                                       "MAX-9.2dB", "MAX-11.5dB", "MAX-14.6dB", "MAX-17.1dB" };
  const uint8_t magn_target[] = { 24, 27, 30, 33, 36, 38, 40, 42 };
  const char* const carrier_sense_rel_thr[] = { "disabled", "6 dB RSSI", "10 dB RSSI", "14 dB RSSI" };
  const uint8_t t_event1[] = { 4, 6, 8, 12, 16, 24, 32, 48 };
  const char* const marcstatestr[] = { "SLEEP.SLEEP", "IDLE.IDLE", "XOFF.SOFF", "MANCAL.VCOON_MC",
                                       "MANCAL.REGON_MC", "MANCAL.MANCAL", "FS_WAKEUP.VCOON", "FS_WAKEUP.REGON",
                                       "CALIBRATE.STARTCAL", "SETTLING.BWBOOST", "SETTLING.FS_LOCK", "SETTLING.IFADCON",
                                       "CALIBRATE.ENDCAL", "RX.RX", "RX.RX_END", "RX.RX_RST",
                                       "TXRX_SETTLING.TXRX_SWITCH", "RXFIFO_OVERFLOW.RXFIFO_OVERFLOW", "FSTXON.FSTXON", "TX.TX",
                                       "TX.TX_END", "RXTX_SETTLING.RXTX_SWITCH", "TXFIFO_UNDERFLOW.TXFIFO_UNDERFLOW" };

  const uint32_t f_xosc = 26000000UL;
  const uint32_t f_aclk = 32768UL;

  command const char* Rf1aDumpConfig.marcstate (uint8_t v) {
    if (v < (sizeof(marcstatestr)/sizeof(*marcstatestr))) {
      return marcstatestr[v];
    }
    return 0;
  }

  command void Rf1aDumpConfig.display (const rf1a_config_t* cp) {
    uint8_t r8;
    uint64_t f_xosc_ull = f_xosc;
    int i;
    const char* active_mode[] = { "active high", "active low" };

    if (0 == cp) {
      cp = &rf1a_default_config;
    }

    printf("PARTNUM: 0x%02x ; VERSION: 0x%02x\r\n",
           cp->partnum, cp->version);
    r8 = cp->iocfg0;
    printf("GDO0: %u, %s # %s\r\n", r8 & 0x3F, active_mode[!!(r8 & 0x40)], gdo_signal[r8 & 0x3F]);
    r8 = cp->iocfg1;
    printf("GDO1: %u, %s # %s\r\n", r8 & 0x3F, active_mode[!!(r8 & 0x40)], gdo_signal[r8 & 0x3F]);
    r8 = cp->iocfg2;
    printf("GDO2: %u, %s # %s\r\n", r8 & 0x3F, active_mode[!!(r8 & 0x40)], gdo_signal[r8 & 0x3F]);
    r8 = cp->fifothr;
    printf("FIFOTHR: RX Attenuation: %u dB; TX_THR: %u ; RX_THR: %u\r\n",
           close_in_rx[3 & (r8 >> 4)], fifo_thr_tx[r8 & 0x0F], fifo_thr_rx[r8 & 0x0F]);
    printf("SYNC: 0x%04x ; PKTLEN: %u\r\n", (cp->sync1 << 8) | cp->sync0, cp->pktlen);
    r8 = cp->pktctrl1;
    printf("PQT: %u ; CRC_AUTOFLUSH: %u ; APPEND_STATUS: %u ; ADDR_CHK: %u (%s)\r\n",
           r8 >> 6, !!(r8 & 0x08),
           !!(r8 & 0x04), r8 & 0x03, adr_chk[r8 & 0x03]);           
    r8 = cp->pktctrl0;
    i = (r8 >> 4) & 0x03;
    printf("WHITE_DATA: %u, PKT_FORMAT: %u (%s) ; CRC_EN: %u\r\nLENGTH_CONFIG: %u (%s) ; ",
           !!(r8 & 0x40), i, pkt_format[i],
           !!(r8 & 0x04), i, length_config[i]);
    r8 = cp->mdmcfg1;
    i = 0x07 & (r8 >> 4);
    printf("NUM_PREAMBLE: 0x%x (%d bytes)\r\n", i, num_preamble[i]);
    printf("ADDR: 0x%02x ; CHANNR: %u\r\n", cp->addr, cp->channr);
    {
      uint8_t freq_if = 0x0F & cp->fsctrl1;
      uint8_t freqoff = cp->fsctrl0;
      uint32_t freq = ((((uint32_t)cp->freq2)) << 16
                       | (((uint32_t)cp->freq1)) << 8
                       | (cp->freq0));

      printf("FREQ_IF: %u ; FREQOFF: %u ; FREQ: 0x%lx (%lu)\r\n",
             freq_if, freqoff, freq, freq);
      printf("f_XOSC: %lu Hz ; f_IF: %lu Hz ; f_carrier: %lu Hz\r\n",
             f_xosc,
             (f_xosc * freq_if) >> 10,
             (uint32_t)((f_xosc_ull * freq) >> 16));
    }
    {
      uint8_t chanbw_e;
      uint8_t chanbw_m;
      uint8_t drate_e;
      uint8_t drate_m;
      uint8_t chanspc_e;
      uint8_t chanspc_m;
      uint64_t t_ull;
      uint32_t bw_carrier;
      uint32_t r_data_baud;
      uint32_t r_data_Bps;
      uint32_t df_channel;

      r8 = cp->mdmcfg4;
      chanbw_e = (r8 >> 6);
      t_ull = 1 << chanbw_e;
      chanbw_m = (r8 >> 4) & 0x03;
      bw_carrier = (uint32_t) (f_xosc_ull / (8 * (4 + chanbw_m) * t_ull));
      drate_e = r8 & 0x0F;
      drate_m = cp->mdmcfg3;
      t_ull = 1;
      t_ull <<= drate_e;
      t_ull *= (256 + drate_m) * f_xosc_ull;
      r_data_baud = (uint32_t)(t_ull >> 28);
      r_data_Bps = r_data_baud / 8;
      r8 = cp->mdmcfg2;
      if (0x08 & r8) {
        r_data_Bps /= 2;
      }

      chanspc_e = 0x03 & cp->mdmcfg1;
      chanspc_m = cp->mdmcfg0;
      df_channel = (uint32_t)((f_xosc_ull * (256UL + chanspc_m) * (1UL << chanspc_e)) >> 18);
      r8 = cp->deviatn;
      printf("M, E: CHANBW: %u , %u ; DRATE: %u , %u ; CHANSPC: %u , %u ; DEVIATN: %u , %u\r\n",
             chanbw_m, chanbw_e, drate_m, drate_e, chanspc_m, chanspc_e, r8 & 0x07, 0x07 & (r8 >> 4));
      printf("BW_carrier: %lu Hz ; R_DATA: %lu Baud (%lu Bps); df_channel: %lu Hz\r\n",
             bw_carrier, r_data_baud, r_data_Bps, df_channel);
    }

    r8 = cp->mdmcfg2;
    i = 0x03 & (r8 >> 4);
    printf("DEM_DCFILT_OFF: %u ; MOD_FORMAT: %u (%s)\r\n",
           !!(r8 & 0x80), i, mod_format[i]);
    i = r8 & 0x07;
    printf("MANCHESTER_EN %u ; SYNC_MODE %u (%s)\r\n",
           !!(r8 & 0x08), i, sync_mode[i]);

    r8 = cp->mcsm2;
    printf("RX_TIME_RSSI: %u ; RX_TIME_QUAL: %u ; RX_TIME: %u\r\n",
           !!(r8 & 0x10), !!(r8 & 0x08), 0x07 & r8);

    r8 = cp->mcsm1;
    i = 0x03 & (r8 >> 4);
    printf("CCA_MODE: %u (%s) ; ", i, cca_mode[i]);
    i = 0x03 & (r8 >> 2);
    printf("RXOFF_MODE: %u (%s) ; ", i, rxtxoff_mode[i]);
    i = 0x03 & r8;
    printf("TXOFF_MODE: %u (%s)\r\n", i, rxtxoff_mode[i]);

    r8 = cp->mcsm0;
    i = 0x03 & (r8 >> 4);
    printf("FS_AUTOCAL: %u (%s) ; PIN_CTRL_EN: %u ; XOSC_FORCE_ON: %u\r\n",
           i, fs_autocal[i], !!(r8 & 0x02), !!(r8 & 0x01));

    r8 = cp->foccfg;
    printf("FOC_BS_CS_GATE: %u ; FOC_PRE_K: %u ; FOC_POST_K: %u ; FOC_LIMIT: %u\r\n",
           !!(r8 & 0x20), (0x03 & (r8 >> 4)), !!(r8 & 0x04), 0x03 & r8);

    r8 = cp->bscfg;
    printf("BS_PRE_K: %u ; BS_PRE_KP: %u ; BS_POST_K: %u ; BS_POST_KP: %u; BS_LIMIT: %u\r\n",
           0x03 & (r8 >> 6), 0x03 & (r8 >> 4), !!(r8 & 0x08), !!(r8 & 0x04), 0x03 & r8);

    r8 = cp->agcctrl2;
    i = 0x07 & (r8 >> 3);
    printf("MAX_DVGA_GAIN: %u ; MAX_LNA_GAIN: %u (%s) ; MAGN_TARGET: %u (%u dB)\r\n",
           0x03 & (r8 >> 6), i, max_lna_gain[i], r8 & 0x07, magn_target[r8 & 0x07]);

    r8 = cp->agcctrl1;
    i = 0x03 & (r8 >> 4);
    printf("AGC_LNA_PRIORITY: %u ; CARRIER_SENSE_REL_THR: %u (%s)\r\n",
           !!(r8 & 0x04), i, carrier_sense_rel_thr[i]);
    printf("CARRIER_SENSE_ABS_THR: ");
    if (0x08 & r8) {
      if (0 == (0x07 & r8)) {
        printf("disabled");
      } else {
        printf("%u dB below MAGN_TARGET", 8 - (0x07 & r8));
      }
    } else {
      if (0 == (0x07 & r8)) {
        printf("at MAGN_TARGET");
      } else {
        printf("%u dB above MAGN_TARGET", (0x07 & r8));
      }
    }
    printf("\r\n");

    r8 = cp->agcctrl0;
    printf("HYST_LEVEL: %u ; WAIT_TIME: %u ; AGC_FREEZE: %u ; FILTER_LENGTH: %u\r\n",
           0x03 & (r8 >> 6), 0x03 & (r8 >> 4), 0x03 & (r8 >> 2), 0x03 & r8);

    {
      uint16_t event0 = (cp->worevt1 << 8) + cp->worevt0;
      uint8_t wor_res;
#if 0
      uint16_t wor_time = (cp->wortime1 << 8) + cp->wortime0;
#endif
      uint32_t t_event0;

      r8 = cp->worctrl;
      i = 0x07 & (r8 >> 4);
      wor_res = 0x03 & r8;
      printf("ACLK_PD: %u ; EVENT0: %u ACLK; EVENT1: %u (%u ACLK) ; WOR_RES: %u (%u periods)\r\n",
             !!(0x80 & r8), event0, i, t_event1[i], wor_res, 1U << (5 * wor_res));
      t_event0 = event0;
      t_event0 <<= (5 * wor_res);
      printf("f_ACLK: %lu Hz; t_event0: ", f_aclk);
      if (t_event0 > (128 * f_aclk)) {
        printf("%lu sec", (t_event0 / f_aclk)); 
      } else if (t_event0 >= f_aclk) {
        printf("%lu ms", (t_event0 * 1000U / f_aclk));
      } else {
        printf("%lu us", (uint32_t)(1000000UL * (uint64_t)t_event0 / f_aclk));
      }
#if 0
      printf(" ; WOR Time: %u", wor_time);
#endif
      printf("\r\n");
    }

    r8 = cp->frend1;
    printf("LNA_CURRENT: %u ; LNA2MIX_CURRENT: %u ; LODIF_BUF_CURRENT_RX: %u\r\nMIX_CURRENT: %u ; ",
           0x03 & (r8 >> 6), 0x03 & (r8 >> 4), 0x03 & (r8 >> 2), 0x03 & r8);
    r8 = cp->frend0;
    printf("LODIV_BUF_CURRENT_TX: %u ; PA_POWER: %u\r\n",
           0x03 & (r8 >> 4), 0x07 & r8);
    printf("PATABLE:");
    for (i = 0; i < sizeof(cp->patable) / sizeof(*cp->patable); ++i) {
      printf(" 0x%02x", cp->patable[i]);
    }
    printf("\r\n");

    printf("FSCAL0: 0x%02x ; FSCAL1: 0x%02x ; FSCAL2: 0x%02x ; FSCAL3: 0x%02x\r\n",
           cp->fscal0, cp->fscal1, cp->fscal2, cp->fscal3);
           
    printf("FSTEST: 0x%02x ; PTEST: 0x%02x ; AGCTEST: 0x%02x\r\n",
           cp->fstest, cp->ptest, cp->agctest);
           
    printf("TEST0: 0x%02x ; TEST1: 0x%02x ; TEST2: 0x%02x\r\n",
           cp->test0, cp->test1, cp->test2);

#if 0
    r8 = cp->lqi;
    printf("FREQEST: %d ; CRC_OK: %u ; LQI: %d ; RSSI: %d\r\n",
           (int8_t)cp->freqest,
           !!(r8 & 0x80), 0x7F & r8,
           cp->rssi);
#endif

    return;
  }
}
