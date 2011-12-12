interface HplChipconSpi {
	/**
	 * Send a command strobe and return the chip status byte.
	 */
	command uint8_t strobe(uint8_t cmd);
	
	/**
	 * Read a register.
	 */
	command uint8_t readRegister(uint8_t reg);
	
	/**
	 * Write a register.
	 */
	command void writeRegister(uint8_t reg, uint8_t value);
	
	/**
	 * Burst read /len/ bytes into a buffer.
	 * The address should have the burst bit set.
	 */
	command void read(uint8_t addr, uint8_t* buffer, uint8_t len);
	
	/**
	 * Burst write /len/ bytes from a buffer.
	 * The address should have the burst bit set.
	 */
	command void write(uint8_t addr, uint8_t* buffer, uint8_t len);
}