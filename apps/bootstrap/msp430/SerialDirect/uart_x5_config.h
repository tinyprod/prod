#ifndef __UART_X5_CONFIG_H__
#define __UART_X5_CONFIG_H__

const msp430_usci_config_t uart_config = {
  ctlw0 : (0 << 8) | UCSSEL__SMCLK,	/* 8000000 SMCLK */
  brw   : 52,				/* 9600 */
  /*       ucbrf       ucbrs  */
  mctl  : (1 << 4) | (0 << 1) | UCOS16
};

#endif	/* __UART_X5_CONFIG_H__ */
