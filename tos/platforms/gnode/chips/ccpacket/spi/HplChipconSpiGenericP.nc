/**
 * Provides a generic implementation of the SPI protocol using an SpiByte provider.
 */
module HplChipconSpiGenericP {
	provides {
		interface HplChipconSpi;
	}
	
	uses {
		interface SpiByte;
		interface SpiByte as WriteOnly;
		interface SpiByte as ReadOnly;
	}
}
	
implementation {
	
	command uint8_t HplChipconSpi.strobe(uint8_t strobe) {
		return call SpiByte.write(strobe);
	}
	
	command uint8_t HplChipconSpi.readRegister(uint8_t reg) {
		call WriteOnly.write(reg);
		return call SpiByte.write(0);
	}
	
	command void HplChipconSpi.writeRegister(uint8_t reg, uint8_t value) {
		call WriteOnly.write(reg);
		call WriteOnly.write(value);
	}
	
	command void HplChipconSpi.read(uint8_t addr, uint8_t* buffer, uint8_t len) {
		uint8_t i;
		call WriteOnly.write(addr);
		for (i = 0; i < len; i++) {
			buffer[i] = call ReadOnly.write(0);
		}
	}
	
	command void HplChipconSpi.write(uint8_t addr, uint8_t* buffer, uint8_t len) {
		uint8_t i;
		call WriteOnly.write(addr);
		for (i = 0; i < len; i++) {
			call WriteOnly.write(buffer[i]);
		}
	}
}
