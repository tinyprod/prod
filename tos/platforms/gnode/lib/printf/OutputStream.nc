interface OutputStream {
	command error_t write(uint8_t* buf, uint16_t len);
	event void writeDone(error_t error);
}