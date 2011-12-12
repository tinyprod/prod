/**
 * Convert the output of the internal voltage measurement to millivolts. 
 */
generic module VoltageP() {
	provides interface Read<uint16_t>;
	uses interface Read<uint16_t> as SubRead;
}

implementation {
	
	command error_t Read.read() {
		return call SubRead.read();
	}
	
	event void SubRead.readDone(error_t error, uint16_t val) {
		// measured voltage is VCC/3, 12 bit ADC
		uint32_t millivolts = (val * 3000UL)/4096;
		signal Read.readDone(error, (uint16_t) millivolts);
	}
}
