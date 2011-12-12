/**
 * Provides a BigQueue implementation backed by the SRAM chip.
 */
generic configuration SRAMQueueC(typedef t, uint16_t size, uint16_t offset) {
	provides interface BigQueue<t>;
}

implementation {
	
	components SRAMC, new SRAMQueueP(t, size, offset);
	BigQueue = SRAMQueueP;
	SRAMQueueP.SRAM -> SRAMC;
	
}
