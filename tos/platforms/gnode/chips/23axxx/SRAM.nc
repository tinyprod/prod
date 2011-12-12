interface SRAM {
	command void read(uint16_t addr, uint8_t len, void* buffer);
	command void write(uint16_t addr, uint8_t len, void* buffer);
}
