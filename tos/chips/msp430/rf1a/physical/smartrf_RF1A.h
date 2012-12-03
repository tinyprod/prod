/***************************************************************
 *  SmartRF Studio(tm) Export
 *
 *  Radio register settings specifed with C-code
 *  compatible #define statements.
 *
 ***************************************************************/

#ifndef SMARTRF_CC430_H
#define SMARTRF_CC430_H

#define SMARTRF_RADIO_CC430

#define SMARTRF_SETTING_FSCTRL1    0x06
#define SMARTRF_SETTING_FSCTRL0    0x00
#define SMARTRF_SETTING_FREQ2      0x22
#define SMARTRF_SETTING_FREQ1      0xB1
#define SMARTRF_SETTING_FREQ0      0x3B
#define SMARTRF_SETTING_MDMCFG4    0xC8
#define SMARTRF_SETTING_MDMCFG3    0x93
#define SMARTRF_SETTING_MDMCFG2    0x13
#define SMARTRF_SETTING_MDMCFG1    0x22
#define SMARTRF_SETTING_MDMCFG0    0xF8
#define SMARTRF_SETTING_CHANNR     0x0a
#define SMARTRF_SETTING_DEVIATN    0x34
#define SMARTRF_SETTING_FREND1     0x56
#define SMARTRF_SETTING_FREND0     0x10
#define SMARTRF_SETTING_MCSM0      0x10
#define SMARTRF_SETTING_FOCCFG     0x16
#define SMARTRF_SETTING_BSCFG      0x6C
#define SMARTRF_SETTING_AGCCTRL2   0x03
#define SMARTRF_SETTING_AGCCTRL1   0x40
#define SMARTRF_SETTING_AGCCTRL0   0x91
#if 0
/* Settings emitted by SmartRF Studio */
#define SMARTRF_SETTING_FSCAL3     0xE9
#define SMARTRF_SETTING_FSCAL2     0x2A
#define SMARTRF_SETTING_FSCAL1     0x00
#define SMARTRF_SETTING_FSCAL0     0x1F
#else
/* Settings observed in real world */
#define SMARTRF_SETTING_FSCAL3     0xEF
#define SMARTRF_SETTING_FSCAL2     0x2D
#define SMARTRF_SETTING_FSCAL1     0x25
#define SMARTRF_SETTING_FSCAL0     0x1F
#endif
#define SMARTRF_SETTING_FSTEST     0x59
#define SMARTRF_SETTING_TEST2      0x81
#define SMARTRF_SETTING_TEST1      0x35
#define SMARTRF_SETTING_TEST0      0x09
#define SMARTRF_SETTING_FIFOTHR    0x47
#define SMARTRF_SETTING_IOCFG2     0x2E
#define SMARTRF_SETTING_IOCFG0D    0x29
#define SMARTRF_SETTING_PKTCTRL1   0x04
#define SMARTRF_SETTING_PKTCTRL0   0x45
#define SMARTRF_SETTING_ADDR       0x00
#define SMARTRF_SETTING_PKTLEN     0xFF

/* TinyOS Custom Settings */

// CCA if RSSI < thr unless rx; RX stay in RX ; TX go to RX
#define SMARTRF_SETTING_MCSM1      0x3F

// Default power configuration
#define SMARTRF_SETTING_PATABLE0   0xC0

/** Minimum legal channel number */
#define RF1A_CHANNEL_MIN (10)
/** Maximum legal channel number */
#define RF1A_CHANNEL_MAX (19)

#endif

