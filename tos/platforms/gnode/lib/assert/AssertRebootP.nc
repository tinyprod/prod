/**
 * Handles failed assertions by rebooting the node.
 */
module AssertRebootP {
	uses {
		interface Reboot;
	}
}
implementation {

	/**
	 * Assert a condition is true.
	 */
	void doAssert(bool condition, uint16_t errorCode) __attribute__((C)) {
		if (!condition) call Reboot.reboot();
	}
	
	/**
	 * Assert a condition is false.
	 */
	void doAssertNot(bool condition, uint16_t errorCode) __attribute__((C)) {
		doAssert(!condition, errorCode);
	}
	
	/**
	 * Assert an error code is SUCCESS.
	 */
	void doAssertSuccess(error_t error, uint16_t errorCode) __attribute__((C)) {
		doAssert(error == SUCCESS, errorCode);
	}
	
	/**
	 * Assert a equals b.
	 */
	void doAssertEquals(uint32_t a, uint32_t b, uint16_t errorCode) __attribute__((C)) {
		doAssert(a == b, errorCode);
	}
	
}
