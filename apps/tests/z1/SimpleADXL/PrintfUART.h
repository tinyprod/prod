
#ifndef PRINTFUART_H
#define PRINTFUART_H
#include <stdarg.h>
#include <stdio.h>

#warning including printfUART

#define DEBUGBUF_SIZE 256
char debugbuf[DEBUGBUF_SIZE];
char debugbufROMtoRAM[DEBUGBUF_SIZE];

#define printfUART(__format...) {      \
    sprintf(debugbuf, __format);       \
    writedebug();                      \
}  


/**
 * Initialize the UART port.  Call this from your startup routine.
 */
#define printfUART_init() {atomic printfUART_init_private();}
void printfUART_init_private()
{
    	#warning initialize z1 serial port
		/*
		P3SEL |= 0xC0;                             // P3.6,7 = USCI_A1 TXD/RXD
		UCA1CTL1 |= UCSSEL_1;                     // CLK = ACLK
		UCA1BR0 = 0x03;                           // 32kHz/9600 = 3.41
		UCA1BR1 = 0x00;                           //
		UCA1MCTL = UCBRS1 + UCBRS0;               // Modulation UCBRSx = 3
		UCA1CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
		*/
		P3SEL |= 0x30;                             // P3.4,5 = USCI_A1 TXD/RXD
		UCA0CTL1 |= UCSSEL_1;                     // CLK = ACLK
		UCA0BR0 = 0x03;                           // 32kHz/9600 = 3.41
		UCA0BR1 = 0x00;                           //
		UCA0MCTL = UCBRS1 + UCBRS0;               // Modulation UCBRSx = 3
		UCA0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
}

/**
 * Outputs a char to the UART.
 */
void UARTPutChar(char c)
{
    if (c == '\n')
        UARTPutChar('\r');
  	/*
  	while (!(UC1IFG&UCA1TXIFG));
  		atomic UCA1TXBUF = c;
  	*/
  	while (!(IFG2&UCA0TXIFG));
  		atomic UCA0TXBUF = c;
  	
}

/**
 * Outputs the entire debugbuf to the UART, or until it encounters '\0'.
 */
void writedebug()
{
    uint16_t i = 0;
    
    while (debugbuf[i] != '\0' && i < DEBUGBUF_SIZE)
        UARTPutChar(debugbuf[i++]);
}

#endif  // PRINTFUART_H

