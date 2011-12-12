#include "printf.h"

/**
 * Include this component in your program to be able to use printf() to write to the UART.
 * printf() is declared in printf.h, which this component includes. If your component is processed
 * prior to PrintfC, you may need to include printf.h yourself.
 */
generic configuration PrintfC(uint16_t bufsize) {
	provides interface PrintfFlush;
}

implementation {
	components new PrintfP(bufsize), PutcharC, UartOutputStreamC, PlatformSerialC;

	PrintfFlush = PrintfP;
	
	PrintfP.OutputStream -> UartOutputStreamC;
	PrintfP.UartByte -> PlatformSerialC;
	PrintfP.Putchar -> PutcharC;
}
