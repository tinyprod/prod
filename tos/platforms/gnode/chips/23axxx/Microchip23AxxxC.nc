generic configuration Microchip23AxxxC() {
	provides {
		interface SRAM;
	}
	
	uses {
		interface SpiByte;
		interface GeneralIO as ChipSelect;
	}
}

implementation {
	
	components new Microchip23AxxxP(), MainC;
	SRAM = Microchip23AxxxP;
	SpiByte = Microchip23AxxxP;
	ChipSelect = Microchip23AxxxP;
	MainC.SoftwareInit -> Microchip23AxxxP;
	
}