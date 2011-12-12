#include "Assert.h"

/**
 * Output stream that writes data to a UART.
 */
module UartOutputStreamP {
	
	provides {
		interface OutputStream;
	}
	
	uses {
		interface StdControl as SerialControl;
		interface UartStream;
	}
}

implementation {

	bool started;		// used to start PlatformSerialC on demand

	command error_t OutputStream.write(uint8_t* buf, uint16_t len) {
		if (!started) {
			call SerialControl.start();
			started = TRUE;
		}
		
		return call UartStream.send(buf, len);
	}
	
	task void sendDone() {
		signal OutputStream.writeDone(SUCCESS);
	}
	
	async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t result) {
		post sendDone();
	}
	
	async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t result) {}
	async event void UartStream.receivedByte(uint8_t byte) {}
	
}
