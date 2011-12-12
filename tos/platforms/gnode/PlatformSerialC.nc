/**
 * Use UART0 as the platform UART.
 * Offers AsyncStdControl as well.
 */
configuration PlatformSerialC {
	
	provides interface StdControl;
	provides interface AsyncStdControl;
	provides interface UartStream;
	provides interface UartByte;
	
}

implementation {
	
	components new Msp430UartA0C() as UartC;
	UartStream = UartC;	
	UartByte = UartC;
	
	components PlatformSerialUsciP as PlatformSerial;
	StdControl = PlatformSerial;
	AsyncStdControl = PlatformSerial;
	PlatformSerial.Msp430UartConfigure <- UartC.Msp430UartConfigure;
	PlatformSerial.Resource -> UartC.Resource;
	
}
