#ifndef _H_Msp430Usci_h
#define _H_Msp430Usci_h

#include "msp430hardware.h"

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
  uint8_t ctl0;
  uint8_t ctl1;
  uint8_t br0;
  uint8_t br1;
  uint8_t mctl;
  uint16_t i2coa;
} msp430_usci_config_t;

//see note in Msp430UsciI2CP.nc I2CBasicAddr.read
#define I2C_ONE_BYTE_READ_COUNTER 0xE00

#ifndef TOS_DEFAULT_BAUDRATE
#define TOS_DEFAULT_BAUDRATE 115200
#endif /* TOS_DEFAULT_BAUDRATE */

msp430_usci_config_t msp430_usci_uart_default_config = {
  /* N81 UART mode driven by SMCLK */
  ctl0 : 0,
  ctl1 : UCSSEL_SMCLK,

  /* SLAU259 Table 16-4 2^20Hz 115200: UBR=9, BRS=1, BRF=0 */
  br0 : 9, // 115200
  br1 : 0,
  mctl : UCBRF_0 + UCBRS_1
};

msp430_usci_config_t msp430_usci_spi_default_config = {
  /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
  ctl0 : UCSSEL_SMCLK,
  ctl1 : UCCKPL | UCMSB | UCMST | UCSYNC,
  /* 2x Prescale */
  br0 : 2,
  br1 : 0,
  mctl : 0                      /* Always 0 in SPI mode */
};

msp430_usci_config_t msp430_usci_i2c_default_config = {
  ctl0: UCSYNC|UCMODE_3|UCMM,
  ctl1: UCSSEL_2,
  br0:  0x08,
  br1:  0x00,
  mctl: 0x00,
  i2coa: 'A',
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
