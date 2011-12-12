configuration SRAMC {
	provides interface SRAM;
}

implementation {
	
	components new Microchip23AxxxC(), new SoftwareSpiC(0, 0), GeneralIOC;
	SRAM = Microchip23AxxxC;
	Microchip23AxxxC.SpiByte -> SoftwareSpiC;
	Microchip23AxxxC.ChipSelect -> GeneralIOC.GeneralIO[SRAM_CSN];
	SoftwareSpiC.MOSI -> GeneralIOC.GeneralIO[SRAM_MOSI];
	SoftwareSpiC.MISO -> GeneralIOC.GeneralIO[SRAM_MISO];
	SoftwareSpiC.Clock -> GeneralIOC.GeneralIO[SRAM_SCK];

}
