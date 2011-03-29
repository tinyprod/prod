/**
 *  @author Eric B. Decker
 *  @date   Mar 6 2010
 *
 * Define USE_X1 if using an x1 family chip, 4 MiHz USART based msp430
 * else assumed x2 8 MiHz 2000 series part.
 *
 * ie.  make debugopt -DUSE_X1 telosb
 **/

#include "hardware.h"

#ifdef USE_X1
#include "msp430usart.h"
#else
#include "msp430usci.h"
#endif

#ifdef USE_X1
const msp430_uart_union_config_t uart_config = { {
  ubr    : UBR_4MIHZ_4800,
  umctl  : UMCTL_4MIHZ_4800,
  ssel   : 2,
  pena   : 0,
  pev    : 0,
  spb    : 0,
  clen   : 1,
  listen : 0,
  mm     : 0,
  ckpl   : 0,
  urxse  : 0,
  urxeie : 1,
  urxwie : 0,
  utxe   : 1,
  urxe   : 1
  } };
#else
const msp430_uart_union_config_t uart_config = { {
  ubr:		UBR_8MIHZ_4800,
  umctl:	UMCTL_8MIHZ_4800,
  ucmode:	0,			// uart
  ucspb:	0,			// one stop
  uc7bit:	0,			// 8 bit
  ucpar:	0,			// odd parity (but no parity)
  ucpen:	0,			// parity disabled
  ucrxeie:	0,			// err int off
  ucssel:	2,			// smclk
  utxe:		1,			// enable tx
  urxe:		1,			// enable rx
} };
#endif

uint16_t rx_ints, tx_ints;
volatile uint16_t start = 1;

module SerialDirectP {
  uses {
#ifdef USE_X1
    interface HplMsp430Usart as Port;
    interface HplMsp430UsartInterrupts as PortInt;
#else
    interface HplMsp430UsciA as Port;
    interface HplMsp430UsciInterrupts as PortInt;
#endif
    interface Boot;
  }
}
implementation {
  event void Boot.booted() {
    uint8_t b;

    while (!start)
      nop();
    call Port.setModeUart((msp430_uart_union_config_t *) &uart_config);
    b = 0;
    call Port.tx(b++);
    while(1) {
      if (call Port.isTxIntrPending())
	call Port.tx(b++);
    }
  }

  async event void PortInt.txDone() {
    tx_ints++;
  }

  async event void PortInt.rxDone(uint8_t data) {
    uint8_t tmp;

    rx_ints++;
    tmp = call Port.rx();
  }
}
