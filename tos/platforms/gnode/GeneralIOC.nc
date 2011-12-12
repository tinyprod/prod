/**
 * Wraps/renames Msp430GeneralIOC.
 */
configuration GeneralIOC {
	provides {
		interface GeneralIO[uint8_t pin];
		interface GpioInterrupt[uint8_t pin];
	}
}

implementation {

	components Msp430GeneralIOC;
	GeneralIO = Msp430GeneralIOC;
	GpioInterrupt = Msp430GeneralIOC;
	
}
