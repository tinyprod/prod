#include "AssertUart.h"

/**
 * Outputs failed assertions by repeatedly writing a message to the UART.
 * After N messages, reboot the node. This can be suppressed by defining
 * ASSERT_UART_NO_REBOOT.
 */
configuration AssertUartC {
	uses interface PrintfFlush;
}

implementation {
	
	components AssertUartP, PlatformSerialC, BusyWaitMicroC, LedsC, RebootC;

	PrintfFlush = AssertUartP;
	AssertUartP.UartControl -> PlatformSerialC;
	AssertUartP.UartByte -> PlatformSerialC;
	AssertUartP.UartStream -> PlatformSerialC;
	AssertUartP.BusyWait -> BusyWaitMicroC;
	AssertUartP.Leds -> LedsC;
	AssertUartP.Reboot -> RebootC;

}
