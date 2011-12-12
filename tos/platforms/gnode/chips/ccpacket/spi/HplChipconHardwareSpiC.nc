/**
 * Use USCI B0 as SPI for the radio.
 */
configuration HplChipconHardwareSpiC {
	provides {
		interface Resource;
		interface HplChipconSpi;
	}
}

implementation {
	
	components HplChipconSpiB0P as Spi, DedicatedResourceC, PlatformP;
	Resource = DedicatedResourceC;
	HplChipconSpi = Spi;
	Spi.Init <- PlatformP.InitLevel[2];
	
	components HplMsp430GeneralIOC as IO;
	Spi.SIMO -> IO.UCB0SIMO;
	Spi.SOMI -> IO.UCB0SOMI;
	Spi.UCLK -> IO.UCB0CLK;
	
}
