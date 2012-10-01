#ifndef _H_Msp430Usci_h
#define _H_Msp430Usci_h

#include "msp430hardware.h"

#ifndef UCSSEL__SMCLK

/*
 * Both the x2 and x5 families have UCSIs and need a clock source.
 * The x5 cpu header files define UCSSEL__SMCLK but the x2 headers
 * don't  (please TI, can you be more consistent?...   nah.  that's
 * fine, we'll deal)
 *
 * Note: this is x2xxx/usci/msp430usci.h and is inherently an x2 file.
 */

#define UCSSEL__SMCLK       (0x80)    /* USCI 0 Clock Source: SMCLK */
#endif

/* MSP430_USCI_RESOURCE is used for USCI_IDs */
#define MSP430_USCI_RESOURCE "Msp430Usci.Resource"

#define MSP430_USCI_A0_RESOURCE "Msp430Usci.A0.Resource"
#define MSP430_USCI_B0_RESOURCE "Msp430Usci.B0.Resource"
#define MSP430_USCI_A1_RESOURCE "Msp430Usci.A1.Resource"
#define MSP430_USCI_B1_RESOURCE "Msp430Usci.B1.Resource"
#define MSP430_USCI_A2_RESOURCE "Msp430Usci.A2.Resource"
#define MSP430_USCI_B2_RESOURCE "Msp430Usci.B2.Resource"
#define MSP430_USCI_A3_RESOURCE "Msp430Usci.A3.Resource"
#define MSP430_USCI_B3_RESOURCE "Msp430Usci.B3.Resource"

enum {
  MSP430_USCI_Inactive,
  MSP430_USCI_UART,
  MSP430_USCI_SPI,
  MSP430_USCI_I2C,
};

/**
 * Aggregates basic configuration registers for an MSP430 USCI.
 * These are specifically the registers common to all configurations.
 * Mode-specific configuration data should be provided elsewise.
 */
typedef struct msp430_usci_config_t {
  uint8_t ctl0;				/* various control bits, msb */
  uint8_t ctl1;				/* clock select and swreset, lsb */
  uint8_t br0;				/* lsb divider */
  uint8_t br1;				/* msb divider */
  uint8_t mctl;
  uint16_t i2coa;
} msp430_usci_config_t;

/*
 * see Msp430UsciI2CP.nc, I2CBasicAddr.read.
 *
 * I2C_ONE_BYTE_READ_COUNTER is used as a limit to keep
 * the routine from going infinite when things go wrong.
 *
 * DEPRECATED.   It is going away!!!!
 *
 * The x5 code has been converted to use time via Platform raw time
 * interfaces.   The x2 code currently uses the counters.   This
 * should be changed by the x2 folks.
 *
 * x5 uses 0x500, x2 uses 0xe00 can they be the same?
 */

#define I2C_ONE_BYTE_READ_COUNTER 0x0E00

#ifndef TOS_DEFAULT_BAUDRATE
#define TOS_DEFAULT_BAUDRATE 115200
#endif /* TOS_DEFAULT_BAUDRATE */


/*
 * The following default configurations assume SMCLK clock is 1MiHz (2^20Hz).
 *
 * WARNING: This is not necessarily a good assumption.    Choice of clocks is
 * really a platform thing and should be provided in some fashion by the platform.
 *
 * The common definition here is a carry over from the old initial way that T2 dealt
 * with this issue.
 *
 * In addition, there are issues with assuming binary vs. decimal clocks.  For example
 * the msp430f5438a with out tweak the PMM wants to be clocked no faster than 8,000,000
 * (8 MHz).
 */

msp430_usci_config_t msp430_usci_uart_default_config = {
  /* N81 UART mode driven by SMCLK */
  ctl0 : 0,
  ctl1 : UCSSEL__SMCLK,

  /* SLAU259 Table 16-4 2^20Hz 115200: UBR=9, BRS=1, BRF=0 */
  br0  : 9,
  br1  : 0,
  mctl : UCBRF_0 | UCBRS_1,
  i2coa: 0
};

msp430_usci_config_t msp430_usci_spi_default_config = {
  /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
  ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,
  ctl1 : UCSSEL__SMCLK,
  br0  : 2,			/* 2x Prescale */
  br1  : 0,
  mctl : 0,
  i2coa: 0
};

/*
 * Should the default be the following?  MM (multi-master) seems
 * like it should be a platform specific thing.
 * ctl0 : (UCMST | UCMODE_3 | UCSYNC),
 *
 * clock divisor is definitely a platform specific thing.   The
 * default should probably be SMCLK/div ~= 100kbps.
 *
 * MM vs. SM is also a platform thing.   But for now we let the
 * application or platform override it.
 */

#ifndef MSP430_I2C_MASTER_MODE
/*
 * default to multi-master, because the usci-bf code
 * was originally written as a multi-master.
 */
#define MSP430_I2C_MASTER_MODE UCMM
#endif


#ifndef MSP430_I2C_DIVISOR
#define MSP430_I2C_DIVISOR 10
#endif

msp430_usci_config_t msp430_usci_i2c_default_config = {
  ctl0 : UCSYNC | UCMODE_3 | MSP430_I2C_MASTER_MODE,
  ctl1 : UCSSEL__SMCLK,
  br0  : MSP430_I2C_DIVISOR,		/* SMCLK/div */
  br1  : 0,				/* 1*2^20/div -> 104,858 Hz */
  mctl : 0,
  i2coa: 0x41,
};

enum {
  /** Bit set in Msp430UsciError.condition parameter when a framing
   * error (UART) or bus conflict (SPI) has been detected.  Applies in
   * UART mode, and SPI 4-wire master mode. */
  MSP430_USCI_ERR_Framing = UCFE,
  /** Bit set in Msp430UsciError.condition parameter when an overrun
   * error (lost character on input) has been detected.  Applies in
   * UART and SPI modes. */
  MSP430_USCI_ERR_Overrun = UCOE,
  /** Bit set in Msp430UsciError.condition parameter when a parity
   * error has been detected.  Applies in UART mode. */
  MSP430_USCI_ERR_Parity = UCPE,
  /** Mask for all UCxySTAT bits that represent reportable errors. */
  MSP430_USCI_ERR_UCxySTAT = MSP430_USCI_ERR_Framing | MSP430_USCI_ERR_Overrun | MSP430_USCI_ERR_Parity,
};

/**
 * TODO: unify with x2xxx usci top level.
 * These typedefs should make it such that switching to the x2xxx
 * config interfaces (Msp430UartConfiguration, Msp430I2CConfiguration,
 * Msp430SpiConfiguration) can be done by simply dereferencing the
 * relevant portion of the unified usci_config_t.
 * 
 * This wastes a little space, since UART requires 8 bytes for all its
 * registers, while SPI only requires 4 and I2C only requires 6.
 */

#ifdef notdef
      typedef struct {
        uint8_t uctl0;
        uint8_t uctl1;
        uint16_t ubr;
        uint8_t mctl;
        uint8_t irtctl;
        uint8_t irrctl;
        uint8_t abctl;
      } msp430_uart_registers_t;
      //reorder/expand msp430_uart_config_t accordingly

      typedef struct { 
        uint8_t uctl0;
        uint8_t uctl1;
        uint16_t ubr;
        uint8_t unused[4];
      } msp430_spi_registers_t;
      //reorder msp430_spi_config_t accordingly

      typedef struct {
        uint8_t uctl0;
        uint8_t uctl1;
        uint16_t ubr;
        uint16_t i2coa;
        uint8_t unused[2];
      } msp430_i2c_registers_t;
      //reorder/expand msp430_i2c_config_t accordingly

      typedef union{
        msp430_uart_union_config_t uartConfig;
        msp430_spi_union_config_t spiConfig;
        msp430_i2c_union_config_t i2cConfig;
      } msp430_usci_config_t;

#endif	/* notdef */

#endif // _H_Msp430Usci_h
