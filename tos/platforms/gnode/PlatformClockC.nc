configuration PlatformClockC {
	provides interface Init;
}

implementation {
	components Msp430ClockC;
	Init = Msp430ClockC;
}
