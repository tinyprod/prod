configuration PlatformPinsC {
	provides interface Init;
}

implementation {
	components Msp430GeneralIOC;
	Init = Msp430GeneralIOC;
}
