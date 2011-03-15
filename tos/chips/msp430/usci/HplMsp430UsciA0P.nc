/*
 * Copyright (c) 2010-2011, Eric B. Decker
 * Copyright (c) 2009 DEXMA SENSORS SL
 * Copyright (c) 2005-2006, Arch Rock Corporation
 * Copyright (c) 2004-2005, Technische Universitaet Berlin
 * All rights reserved.
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

#include "msp430usci.h"

/*
 * Implementation of usci A0 (uart or spi) low level functionality - stateless.
 * Setting a mode will by default disable USCI-Interrupts.
 *
 * @author: Jan Hauer <hauer@tkn.tu-berlin.de>
 * @author: Jonathan Hui <jhui@archedrock.com>
 * @author: Vlado Handziski <handzisk@tkn.tu-berlin.de>
 * @author: Joe Polastre
 * @author: Philipp Huppertz <huppertz@tkn.tu-berlin.de>
 * @author: Xavier Orduna <xorduna@dexmatech.com>
 * @author: Eric B. Decker <cire831@gmail.com>
 *
 * A0, A1: uart, spi, irda.
 * B0, B1: spi, i2c.
 *
 * This module interfaces to usciA0: uart or spi.
 */

module HplMsp430UsciA0P @safe() {
  provides interface HplMsp430UsciA as Usci;
  provides interface HplMsp430UsciInterrupts as Interrupts;

  uses interface HplMsp430GeneralIO as SIMO;
  uses interface HplMsp430GeneralIO as SOMI;
  uses interface HplMsp430GeneralIO as UCLK;
  uses interface HplMsp430GeneralIO as URXD;
  uses interface HplMsp430GeneralIO as UTXD;  
  uses interface HplMsp430UsciRawInterrupts as UsciRawInterrupts;
}

implementation {
  MSP430REG_NORACE(IE2);
  MSP430REG_NORACE(IFG2);
  MSP430REG_NORACE(UCA0CTL0);
  MSP430REG_NORACE(UCA0CTL1);
  MSP430REG_NORACE(UCA0STAT);
  MSP430REG_NORACE(UCA0TXBUF);

  async event void UsciRawInterrupts.rxDone(uint8_t temp) {
    signal Interrupts.rxDone(temp);
  }

  async event void UsciRawInterrupts.txDone() {
    signal Interrupts.txDone();
  }

  /* Control registers */
  async command void Usci.setUctl0(msp430_uctl0_t control) {
    UCA0CTL0=uctl02int(control);
  }

  async command msp430_uctl0_t Usci.getUctl0() {
    return int2uctl0(UCA0CTL0);
  }

  async command void Usci.setUctl1(msp430_uctl1_t control) {
    UCA0CTL1=uctl12int(control);
  }

  async command msp430_uctl1_t Usci.getUctl1() {
    return int2uctl1(UCA0CTL1);
  }

  /*
   * setUbr: change the Baud Rate divisor
   *
   * Modify the baud rate divisor for the usci.  For this to
   * take effect the module has to be reset.  And resetting
   * has the effect of bringing TXIFG up.   We duplicate the
   * behaviour of setModeUart or setModeSpi which would be
   * used if setUbr wasn't available.  Following the
   * config modification any interrupts are cleared out.
   *
   * The BR registers are 2 bytes and accessed as two byte references.
   * We want it to be atomic.   On the x2xxx part can UBR be referenced
   * as a single atomic word?  (This is how it is done on the x5xxx).
   * For now we do it atomically and using two byte references (because
   * of the address space and according to TI documentation).
   *
   * WARNING: TXIFG is forced clear after a baud rate change
   * similar to what setMode causes.
   */

  async command void Usci.setUbr(uint16_t control) {
    atomic {
      if (UCA0CTL1 & UCSWRST) {		/* if already reset, set and bail */
	UCA0BR0 = control & 0x00FF;
	UCA0BR1 = (control >> 8) & 0x00FF;
	return;
      }
      call Usci.resetUsci_n();		/* not reset, 1st reset */
      UCA0BR0 = control & 0x00FF;	/* then set. */
      UCA0BR1 = (control >> 8) & 0x00FF;
      call Usci.unresetUsci_n();
      call Usci.clrIntr();
    }
  }

  async command uint16_t Usci.getUbr() {
    atomic {
      return (UCA0BR1 << 8) + UCA0BR0;
    }
  }

  async command void Usci.setUmctl(uint8_t control) {
    UCA0MCTL=control;
  }

  async command uint8_t Usci.getUmctl() {
    return UCA0MCTL;
  }

  async command void Usci.setUstat(uint8_t control) {
    UCA0STAT = control;
  }

  async command uint8_t Usci.getUstat() {
    return UCA0STAT;
  }

  /*
   * Reset/unReset
   *
   * resetUsci(bool): (deprecated) TRUE puts device into reset, FALSE takes it out.  But this
   *   requires pushing the parameter on the stack and all those extra instructions.
   *
   * {un,}resetUsci_n(): reset and unreset the device but result in single instruction that
   *   sets or clears the appropriate bit in the h/w.
   */
  async command void Usci.resetUsci(bool reset) {
    if (reset)
      SET_FLAG(UCA0CTL1, UCSWRST);
    else
      CLR_FLAG(UCA0CTL1, UCSWRST);
  }

  async command void Usci.resetUsci_n() {
    SET_FLAG(UCA0CTL1, UCSWRST);
  }

  async command void Usci.unresetUsci_n() {
    CLR_FLAG(UCA0CTL1, UCSWRST);
  }

  bool isSpi() {
    msp430_uctl0_t tmp;

    tmp = int2uctl0(UCA0CTL0);
    return (tmp.ucsync && tmp.ucmode != 3);
  }

  bool isI2C() {
    msp430_uctl0_t tmp;

    tmp = int2uctl0(UCA0CTL0);
    return (tmp.ucsync && tmp.ucmode == 3);
  }

  bool isUart() {
    msp430_uctl0_t tmp;

    tmp = int2uctl0(UCA0CTL0);
    return (tmp.ucsync == 0);
  }

  async command bool Usci.isSpi() {
    return isSpi();
  }

  async command msp430_uscimode_t Usci.getMode() {
    if (isSpi())
      return USCI_SPI;
    if (isI2C())
      return USCI_I2C;
    if (isUart())
      return USCI_UART;

    return USCI_NONE;
  }

  async command void Usci.enableSpi() {
    atomic {
      call SIMO.selectModuleFunc(); 
      call SOMI.selectModuleFunc();
      call UCLK.selectModuleFunc();
    }
  }

  async command void Usci.disableSpi() {
    atomic {
      call SIMO.selectIOFunc();
      call SOMI.selectIOFunc();
      call UCLK.selectIOFunc();
    }
  }

  void configSpi(msp430_spi_union_config_t* config) {
    UCA0CTL1 = (config->spiRegisters.uctl1 | UCSWRST);
    UCA0CTL0 = (config->spiRegisters.uctl0 | UCSYNC);
    call Usci.setUbr(config->spiRegisters.ubr);
    call Usci.setUmctl(0);		/* MCTL <- 0 if spi */
  }

  /*
   * setModeSpi: configure the usci for spi mode
   *
   * note: make sure all interrupts are clear when taking the port
   * out of reset.  There is an assumption in the system that the
   * tx path needs a first write to fire off the interrupt system.
   *
   * Also note that resetting the usci will clear any interrupt enables
   * for the device.  Don't need to explicitly disableIntr.
   */
  async command void Usci.setModeSpi(msp430_spi_union_config_t* config) {
    atomic {
      call Usci.resetUsci_n();
      call Usci.enableSpi();
      configSpi(config);
      call Usci.unresetUsci_n();
      call Usci.clrIntr();
    }    
  }

  async command bool Usci.isTxIntrPending(){
    if (IFG2 & UCA0TXIFG)
      return TRUE;
    return FALSE;
  }

  async command bool Usci.isRxIntrPending(){
    if (IFG2 & UCA0RXIFG)
      return TRUE;
    return FALSE;
  }

  async command void Usci.clrTxIntr(){
    IFG2 &= ~UCA0TXIFG;
  }

  /*
   * clear any pending RxIntr.
   *
   * We want to clean out atomically any pending rx interrupt pending.
   * This should also clean out any error bits that might have been set.
   * The best way to do this is to simply read the RXBUF.  The TI hardware
   * atomically cleans out any error indicators and the IFG.
   */
  async command void Usci.clrRxIntr() {
    uint8_t temp = call Usci.rx();
  }

  /*
   * clrIntr: clear all rx and tx interrupts
   *
   * clear any pending interrupts.  Intended to be used when
   * starting up a port and we want a pristine state.
   */
  async command void Usci.clrIntr() {
    uint8_t temp;

    atomic {
      temp = call Usci.rx();		/* clean rx side out */
      IFG2 &= ~UCA0TXIFG;		/* and turn off tx ifg */
    }
  }

  async command void Usci.disableRxIntr() {
    IE2 &= ~UCA0RXIE;
  }

  async command void Usci.disableTxIntr() {
    IE2 &= ~UCA0TXIE;
  }

  async command void Usci.disableIntr() {
    IE2 &= ~(UCA0TXIE | UCA0RXIE);
  }

  /*
   * enableRxIntr: allow rx interrupts
   *
   * Will clean out any pending rx interrupt and then enables.
   * This assumes that any left over byte is stale and should be
   * thrown away.   Note that most likely there will be overrun and
   * framing errors too.   Starting pristine is the way to go.
   */
  async command void Usci.enableRxIntr() {
    uint8_t temp;

    atomic {
      temp = call Usci.rx();		/* clean everything out */
      IE2  |=  UCA0RXIE;		/* and enable */
    }
  }

  /*
   * enableTxIntr
   *
   * enable the usci tx h/w to interrupt.
   *
   * Note: The TI module when reset sets UCxxTXIFG so enabling the tx interrupt
   * would cause an interrupt.  Many implementations use this to cause
   * the output path to fire up.
   *
   * TinyOS however assumes that one needs to fire off the first byte and this
   * will cause a TX interrupt later which will fire up the output path.  We
   * clear out the pending tx interrupt.  The first byte must be forced out by
   * hand and then interrupts will continue the process.
   */
  async command void Usci.enableTxIntr() {
    atomic {
      IFG2 &= ~UCA0TXIFG;
      IE2  |=  UCA0TXIE;
    }
  }

  /*
   * enableIntr: enable rx and tx interrupts
   * DEPRECATED.
   *
   * Doesn't make sense to do this.   RX and TX side get dealt with independently
   * so why would this ever get called?    Deprecate.
   *
   * First clear out any pending rx or tx interrupt flags
   * then set interrupt enables.
   */
  async command void Usci.enableIntr() {
    uint8_t temp;
    
    atomic {
      temp = call Usci.rx();		/* clean out rx side */
      IFG2 &= ~UCA0TXIFG;		/* and tx side */
      IE2  |= (UCA0TXIE  | UCA0RXIE);	/* enable both tx and rx */
    }
  }

  async command bool Usci.isBusy() {
    return (UCA0STAT & UCBUSY);
  }

  async command void Usci.tx(uint8_t data) {
    UCA0TXBUF = data;
  }

  async command uint8_t Usci.rx() {
    return UCA0RXBUF;
  }

  async command bool Usci.isUart() {
    return isUart();
  }

  async command void Usci.enableUart() {
    atomic {
      call UTXD.selectModuleFunc();
      call URXD.selectModuleFunc();
    }
  }

  async command void Usci.disableUart() {
    atomic {
      call UTXD.selectIOFunc();
      call URXD.selectIOFunc();
    }
  }

  void configUart(msp430_uart_union_config_t* config) {
    UCA0CTL1 = (config->uartRegisters.uctl1 | UCSWRST);
    UCA0CTL0 = config->uartRegisters.uctl0;		/* ucsync should be off */
    call Usci.setUbr(config->uartRegisters.ubr);
    call Usci.setUmctl(config->uartRegisters.umctl);
  }

  /*
   * setModeUart: configure the usci for uart mode
   *
   * note: make sure all interrupts are clear when taking the port
   * out of reset.  There is an assumption in the system that the
   * tx path needs a first write to fire off the interrupt system.
   *
   * Also note that resetting the usci will clear any interrupt enables
   * for the device.  Don't need to explicitly disableIntr.
   */
  async command void Usci.setModeUart(msp430_uart_union_config_t* config) {
    atomic {
      call Usci.resetUsci_n();
      call Usci.enableUart();
      configUart(config);
      call Usci.unresetUsci_n();
      call Usci.clrIntr();
    }
  }
}
