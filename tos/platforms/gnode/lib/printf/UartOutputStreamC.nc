configuration UartOutputStreamC {
	provides interface OutputStream;
}

implementation {
	components UartOutputStreamP, PlatformSerialC;

	OutputStream = UartOutputStreamP;
	UartOutputStreamP.SerialControl -> PlatformSerialC;
	UartOutputStreamP.UartStream -> PlatformSerialC;
	
}
