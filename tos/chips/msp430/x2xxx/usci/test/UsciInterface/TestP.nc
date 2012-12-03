#include "Timer.h"
#include <msp430usci.h>

void test(uint16_t oa) {
//if (oa) {
    while(oa) {
      oa++;
    }
//}
}

uint16_t goa0, goa1;

module TestP {
  uses {
    interface Boot;
    interface HplMsp430UsciA as Usci;
    interface HplMsp430UsciInterrupts as Interrupt;
  }
}
implementation {
  event void Boot.booted() {
    uint16_t oa0;
    uint16_t oa1;

    call Usci.setUctl0(int2uctl0(0xfe));
    call Usci.getUctl0();
    call Usci.setUctl1(int2uctl1(0xfe));
    call Usci.getUctl1();
    call Usci.setUstat(0xfe);
    call Usci.getUstat();
    call Usci.setModeSpi(&msp430_spi_default_config);
    call Usci.getUmctl();
    call Usci.setUmctl(0x54);
    call Usci.setUbr(call Usci.getUbr());
    call Usci.resetUsci_n();
    call Usci.unresetUsci_n();
    if (call Usci.isSpi()) {
      while(1) {
	nop();
      }
    }
    if (call Usci.isUart()) {
      while(1) {
	nop();
      }
    }
    call Usci.getMode();
    call Usci.disableTxIntr();
    call Usci.disableRxIntr();
    call Usci.disableIntr();
    call Usci.enableTxIntr();
    call Usci.clrIntr();
    call Usci.clrRxIntr();
    call Usci.clrTxIntr();
#ifdef notdef
    call Usci.setModeI2C(&msp430_i2c_default_config);
    call Usci.setModeI2C(&msp430_i2c_default_config);
    call Usci.setGeneralCall();
    oa0 = call Usci.getOwnAddress();
    test(oa0);
    goa0 = oa0;
    call Usci.clearGeneralCall();
    oa1 = call Usci.getOwnAddress();
    test(oa1);
    goa1 = oa1;
    call Usci.disableStopInt();
    call Usci.enableStopInt();
    call Usci.setOwnAddress(0x1000);
    call Usci.disableI2C();
#endif
    while (call Usci.isTxIntrPending()) {
      nop();
    }
    while (call Usci.isRxIntrPending()) {
      nop();
    }
  }

  async event void Interrupt.rxDone(uint8_t data) {}
  async event void Interrupt.txDone() {}
}
