/**
 * Provides a software implementation of the SPI protocol.
 */
generic configuration SoftwareSpiC(uint8_t polarity, uint8_t phase) {
	provides {
		interface Resource;
		interface SpiByte;
		interface SpiPacket;
	}
	
	uses {
		interface GeneralIO as MISO;
		interface GeneralIO as MOSI;
		interface GeneralIO as Clock;
	}
}

implementation {
	
	components new SoftwareSpiP(polarity, phase), MainC;
	
	MainC.SoftwareInit -> SoftwareSpiP;
	
	SoftwareSpiP.MISO = MISO;
	SoftwareSpiP.MOSI = MOSI;
	SoftwareSpiP.Clock = Clock;
	
	SpiByte = SoftwareSpiP;
	SpiPacket = SoftwareSpiP;
	Resource = SoftwareSpiP;
}
