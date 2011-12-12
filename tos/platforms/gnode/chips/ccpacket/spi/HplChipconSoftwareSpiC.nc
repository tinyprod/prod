/**
 * Provides a software implementation of the SPI protocol for use on MSP430 processors
 * that do not have a hardware SPI bus.
 */
configuration HplChipconSoftwareSpiC {
	provides {
		interface Resource;
		interface HplChipconSpi;
	}
}

implementation {
	
	components PlatformP, DedicatedResourceC, HplChipconSpiGenericP, HplChipconSoftwareSpiP as Spi, HplChipconPacketRadioC as Hpl;
	
	Resource = DedicatedResourceC;
	HplChipconSpi = HplChipconSpiGenericP;
	
	HplChipconSpiGenericP.SpiByte -> Spi.SpiByte;
	HplChipconSpiGenericP.WriteOnly -> Spi.WriteOnly;
	HplChipconSpiGenericP.ReadOnly -> Spi.ReadOnly;
	
	Spi.MOSI -> Hpl.SI;
	Spi.MISO -> Hpl.SO;
	Spi.Clock -> Hpl.Clock;
	Spi.Init <- PlatformP.InitLevel[2];
	
}
