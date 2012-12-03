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

/** Structures and definitions relevant to configuring an RF1A radio
 * for specific encoding, frequency, etc.
 * 
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

#ifndef _Rf1aConfigure_h_
#define _Rf1aConfigure_h_

/** Configuration for an RF1A radio.  There must be a one-to-one
 * correspondence between the offsets of the tags in this structure
 * and the address of the corresponding register, since configuration
 * involves walking this structure and storing fields.  Certain tags
 * (those marked as RESERVED or NOWRITE) are skipped during the write
 * process).
 */

typedef struct rf1a_config_t {
  uint8_t iocfg2;             /* 0x00 IOCFG2   - GDO2 output pin configuration  */
  uint8_t iocfg1;             /* 0x01 IOCFG1   - GDO1 output pin configuration  */
  uint8_t iocfg0;             /* 0x02 IOCFG0   - GDO0 output pin configuration  */
  uint8_t fifothr;            /* 0x03 FIFOTHR  - RX FIFO and TX FIFO thresholds */
  uint8_t sync1;              /* 0x04 SYNC1    - Sync word, high byte */
  uint8_t sync0;              /* 0x05 SYNC0    - Sync word, low byte */
  uint8_t pktlen;             /* 0x06 PKTLEN   - Packet length */
  uint8_t pktctrl1;           /* 0x07 PKTCTRL1 - Packet automation control */
  uint8_t pktctrl0;           /* 0x08 PKTCTRL0 - Packet automation control */
  uint8_t addr;               /* 0x09 ADDR     - Device address */
  uint8_t channr;             /* 0x0A CHANNR   - Channel number */
  uint8_t fsctrl1;            /* 0x0B FSCTRL1  - Frequency synthesizer control */
  uint8_t fsctrl0;            /* 0x0C FSCTRL0  - Frequency synthesizer control */
  uint8_t freq2;              /* 0x0D FREQ2    - Frequency control word, high byte */
  uint8_t freq1;              /* 0x0E FREQ1    - Frequency control word, middle byte */
  uint8_t freq0;              /* 0x0F FREQ0    - Frequency control word, low byte */
  uint8_t mdmcfg4;            /* 0x10 MDMCFG4  - Modem configuration */
  uint8_t mdmcfg3;            /* 0x11 MDMCFG3  - Modem configuration */
  uint8_t mdmcfg2;            /* 0x12 MDMCFG2  - Modem configuration */
  uint8_t mdmcfg1;            /* 0x13 MDMCFG1  - Modem configuration */
  uint8_t mdmcfg0;            /* 0x14 MDMCFG0  - Modem configuration */
  uint8_t deviatn;            /* 0x15 DEVIATN  - Modem deviation setting */
  uint8_t mcsm2;              /* 0x16 MCSM2    - Main Radio Control State Machine configuration */
  uint8_t mcsm1;              /* 0x17 MCSM1    - Main Radio Control State Machine configuration */
  uint8_t mcsm0;              /* 0x18 MCSM0    - Main Radio Control State Machine configuration */
  uint8_t foccfg;             /* 0x19 FOCCFG   - Frequency Offset Compensation configuration */
  uint8_t bscfg;              /* 0x1A BSCFG    - Bit Synchronization configuration */
  uint8_t agcctrl2;           /* 0x1B AGCCTRL2 - AGC control */
  uint8_t agcctrl1;           /* 0x1C AGCCTRL1 - AGC control */
  uint8_t agcctrl0;           /* 0x1D AGCCTRL0 - AGC control */
  uint8_t worevt1;            /* 0x1E WOREVT1  - High byte Event0 timeout */
  uint8_t worevt0;            /* 0x1F WOREVT0  - Low byte Event0 timeout */
  uint8_t worctrl;            /* 0x20 WORCTRL  - Wake On Radio control */
  uint8_t frend1;             /* 0x21 FREND1   - Front end RX configuration */
  uint8_t frend0;             /* 0x22 FREND0   - Front end TX configuration */
  uint8_t fscal3;             /* 0x23 FSCAL3   - Frequency synthesizer calibration */
  uint8_t fscal2;             /* 0x24 FSCAL2   - Frequency synthesizer calibration */
  uint8_t fscal1;             /* 0x25 FSCAL1   - Frequency synthesizer calibration */
  uint8_t fscal0;             /* 0x26 FSCAL0   - Frequency synthesizer calibration */
  uint8_t _rcctrl1;           /* RESERVED 0x27 RCCTRL1  - RC oscillator configuration */
  uint8_t _rcctrl0;           /* RESERVED 0x28 RCCTRL0  - RC oscillator configuration */
  uint8_t fstest;             /* NOWRITE 0x29 FSTEST   - Frequency synthesizer calibration control */
  uint8_t ptest;              /* NOWRITE 0x2A PTEST    - Production test */
  uint8_t agctest;            /* NOWRITE 0x2B AGCTEST  - AGC test */
  uint8_t test2;              /* 0x2C TEST2    - Various test settings */
  uint8_t test1;              /* 0x2D TEST1    - Various test settings */
  uint8_t test0;              /* 0x2E TEST0    - Various test settings */

  /* PATABLE is written separately */
  uint8_t patable[8];         /* 0x3E PATABLE  - Output power level (first entry only) */
  /* Status values provided only by Rf1aPhysical.readConfiguration,
   * never written.  It's not clear which of these are useful; the
   * ones I currently think aren't work the ROM are left disabled for
   * now. */
  uint8_t partnum;            /* 0x30 PARTNUM  - Part number */
  uint8_t version;            /* 0x31 VERSION  - Current version number */

#if 0
  uint8_t freqest;            /* 0x32 FREQEST  - Frequency offset estimate */
  uint8_t lqi;                /* 0x33 LQI      - Demodulator eestimate for link quality */
  uint8_t rssi;               /* 0x34 RSSI     - Received signal strength indication */
  uint8_t marcstate;          /* 0x35 MARCSTATE - Control state machine state */
  uint8_t wortime1;           /* 0x36 WORTIME1  - High byte of WOR timer */
  uint8_t wortime0;           /* 0x37 WORTIME0  - Low byte of WOR timer */
  uint8_t pktstatus;          /* 0x38 PKTSTATUS - Current GDOx status and packet status */
  uint8_t vco_vc_dac;         /* 0x39 VCO_VC_DAC - Current setting from PLL calibration module */
#endif

} rf1a_config_t;

/** Most of the rf1a_config_t structure can be accessed via a burst
 * register access starting at address zero.  A burst write should
 * consist of this many bytes.  The subsequent fields of the structure
 * should either be ignored (as they are for testing) or written
 * stored piece-wise (e.g., patable0).
 *
 * @note It is recommended that PATABLE0 be written first, so the
 * subsequent write instruction resets the internal table index
 * register.
 */
#define RF1A_CONFIG_BURST_WRITE_LENGTH (1+FSCAL0)

/** Most of the rf1a_config_t structure can be accessed via a burst
 * register access starting at address zero.  A burst read should
 * consist of this many bytes.  The subsequent fields of the structure
 * must be read piece-wise (e.g., patable).
 *
 * @note It is recommended that PATABLE0 be written first, so the
 * subsequent write instruction resets the internal table index
 * register.
 */
#define RF1A_CONFIG_BURST_READ_LENGTH (1+TEST0)

/** The default values are read from a file named smartrf_RF1A.h,
 * which should contain register settings as exported from SmartRF
 * Studio using the SimplicitTI settings template.
 */
#if TINYOS_SMARTRF_USE_CUSTOM
#warning RF1A Custom (remember to define RF1A_CHANNEL_{MIN,MAX})
#include <smartrf/CUSTOM.h>
#elif TINYOS_SMARTRF_USE_LEGACY
/* Legacy configuration */
#warning RF1A using legacy configuration
#include "smartrf_RF1A.h"
#elif TINYOS_SMARTRF_802_15_4C
#warning RF1A using 779-787 MHz-based 250kbps MSK PHY
#include <smartrf/SRFS7_779_MSK_250K.h>
#else
#warning RF1A using 902.2 MHz-based 50Kbps 135kHz BW 802.15.4g PHY
#include <smartrf/SRFS7_902p2_GFSK_50K_135B.h>
#endif

#ifndef RF1A_CHANNEL_MIN
/** The minimum legal value to use when assigning a channel.  Best
 * practice is that channel zero has a base (not center) frequency at
 * the lower bound of your region's ISM band (902MHz in the US).
 */
#define RF1A_CHANNEL_MIN 0
#endif /* RF1A_CHANNEL_MIN */

#ifndef RF1A_CHANNEL_MAX
/** The maximum legal value to use when assigning a channel.  Best
 * practice is that this channel spans up to but not beyond the upper
 * bound of your region's ISM band (928MHz in the US).
 */
#define RF1A_CHANNEL_MAX 128
#endif /* RF1A_CHANNEL_MIN */

#ifndef SMARTRF_SETTING_IOCFG0
/* Work around bogus register name emitted in early versions of
 * SmartRF Studio */
#define SMARTRF_SETTING_IOCFG0 SMARTRF_SETTING_IOCFG0D
#endif /* SMARTRF_SETTING_IOCFG0 */

/* @TODO@ move this out of the header so it can be more easily overridden */

rf1a_config_t rf1a_default_config = {
  iocfg2: SMARTRF_SETTING_IOCFG2,
#if defined(SMARTRF_SETTING_IOCFG1)
  iocfg1: SMARTRF_SETTING_IOCFG1,
#else // IOCFG1
  iocfg1: 0x2e, // tristate
#endif // IOCFG1
  iocfg0: SMARTRF_SETTING_IOCFG0,
  fifothr: SMARTRF_SETTING_FIFOTHR,
#if defined(SMARTRF_SETTING_SYNC1)
  sync1: SMARTRF_SETTING_SYNC1,
  sync0: SMARTRF_SETTING_SYNC0,
#else
  sync1: 0xd3,
  sync0: 0x91,
#endif
  pktlen: SMARTRF_SETTING_PKTLEN,
  pktctrl1: SMARTRF_SETTING_PKTCTRL1,
  pktctrl0: SMARTRF_SETTING_PKTCTRL0,
  addr: SMARTRF_SETTING_ADDR,
#ifdef USER_SETTING_CHANNR
  channr: USER_SETTING_CHANNR,
#else
  channr: SMARTRF_SETTING_CHANNR,
#endif
  fsctrl1: SMARTRF_SETTING_FSCTRL1,
  fsctrl0: SMARTRF_SETTING_FSCTRL0,
  freq2: SMARTRF_SETTING_FREQ2,
  freq1: SMARTRF_SETTING_FREQ1,
  freq0: SMARTRF_SETTING_FREQ0,
  mdmcfg4: SMARTRF_SETTING_MDMCFG4,
  mdmcfg3: SMARTRF_SETTING_MDMCFG3,
  mdmcfg2: SMARTRF_SETTING_MDMCFG2,
  mdmcfg1: SMARTRF_SETTING_MDMCFG1,
  mdmcfg0: SMARTRF_SETTING_MDMCFG0,
  deviatn: SMARTRF_SETTING_DEVIATN,
#if defined(SMARTRF_SETTING_MCSM2)
  mcsm2: SMARTRF_SETTING_MCSM2,
#else // MCSM2
  mcsm2: 0x07,
#endif // MCSM2
#if defined(SMARTRF_SETTING_MCSM1)
  mcsm1: SMARTRF_SETTING_MCSM1,
#else // MCSM1
  mcsm1: 0x30,
#endif // MCSM1
  mcsm0: SMARTRF_SETTING_MCSM0,
  foccfg: SMARTRF_SETTING_FOCCFG,
  bscfg: SMARTRF_SETTING_BSCFG,
  agcctrl2: SMARTRF_SETTING_AGCCTRL2,
  agcctrl1: SMARTRF_SETTING_AGCCTRL1,
  agcctrl0: SMARTRF_SETTING_AGCCTRL0,
#if defined(SMARTRF_SETTING_WOREVT1)
  worevt1: SMARTRF_SETTING_WOREVT1,
#else // WOREVT1
  worevt1: 0x80,
#endif // WOREVT1
#if defined(SMARTRF_SETTING_WOREVT0)
  worevt0: SMARTRF_SETTING_WOREVT0,
#else // WOREVT0
  worevt0: 0x00,
#endif // WOREVT0
#if defined(SMARTRF_SETTING_WORCTL)
  worctl: SMARTRF_SETTING_WORCTL,
#else // WORCTL
  worctrl: 0xf0,
#endif // WORCTL
  frend1: SMARTRF_SETTING_FREND1,
  frend0: SMARTRF_SETTING_FREND0,
  fscal3: SMARTRF_SETTING_FSCAL3,
  fscal2: SMARTRF_SETTING_FSCAL2,
  fscal1: SMARTRF_SETTING_FSCAL1,
  fscal0: SMARTRF_SETTING_FSCAL0,
  // _rcctrl1 reserved
  // _rcctrl0 reserved
  fstest: SMARTRF_SETTING_FSTEST,
  // ptest do not write
  // agctest do not write
  test2: SMARTRF_SETTING_TEST2,
  test1: SMARTRF_SETTING_TEST1,
  test0: SMARTRF_SETTING_TEST0,
  /* NB: This declaration only specifies the first power level.  You
   * want to use ASK, you write your own. */
#if defined(SMARTRF_SETTING_PATABLE0)
  patable: { SMARTRF_SETTING_PATABLE0 },
#else
  patable: { 0xc6 }
#endif
};

#endif //  _Rf1aConfigure_h_
