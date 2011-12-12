/**
 * Initialize the node by calling all connected Init interfaces.
 * Order of initialization is determined by the "level" they are wired to.
 */
module PlatformP{
	provides interface Init;
	uses interface Init as InitLevel[uint8_t level];
}

implementation {
	command error_t Init.init() {
		uint16_t level;
		for (level = 0; level < 256; level++) {
			call InitLevel.init[level]();
		}

		return SUCCESS;
	}
	
	default command error_t InitLevel.init[uint8_t level]() { return SUCCESS; }
}
