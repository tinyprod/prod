/**
 * Provides the GPIO and SPI interface to a Chipcon radio.
 */
configuration HplChipconPacketRadioC {
	provides {
		interface Resource;
		interface HplChipconSpi;
		interface GeneralIO as SI;
		interface GeneralIO as SO;
		interface GeneralIO as Clock;
		interface GeneralIO as CSn;
		interface GeneralIO as G0;
		interface GeneralIO as G2;
		interface GpioInterrupt as G0Interrupt;
	}
}

implementation {

	#ifdef CHIPCON_SOFTWARE_SPI
		#warning "Falling back to software SPI"
		components HplChipconSoftwareSpiC as SpiC;
	#else
		components HplChipconHardwareSpiC as SpiC;
	#endif
	
	components GeneralIOC;
	
	Resource = SpiC;
	HplChipconSpi = SpiC;
	
	SI = GeneralIOC.GeneralIO[RADIO_SI];
	SO = GeneralIOC.GeneralIO[RADIO_SO];
	Clock = GeneralIOC.GeneralIO[RADIO_CLK];
	CSn = GeneralIOC.GeneralIO[RADIO_CSN];
	G0 = GeneralIOC.GeneralIO[RADIO_G0];
	G2 = GeneralIOC.GeneralIO[RADIO_G2];
	G0Interrupt = GeneralIOC.GpioInterrupt[RADIO_G0];
	
}
