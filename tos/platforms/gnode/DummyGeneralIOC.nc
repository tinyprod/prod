/**
 * Do-nothing GeneralIO/GpioInterrupt implementation.
 */
generic module DummyGeneralIOC(bool high) {
	provides {
		interface GeneralIO;
		interface GpioInterrupt;
		interface HplMsp430GeneralIO;
		interface HplMsp430Interrupt;
	}
}

implementation {
	
	uint8_t value = high;
	uint8_t directionInput = TRUE;
	
	void set() {
		atomic value = TRUE;
	}
	
	void clear() {
		atomic value = FALSE;
	}
	
	void toggle() {
		atomic value = !value;
	}
	
	uint8_t get() {
		atomic return value;
	}
	
	void makeInput() {
		atomic directionInput = TRUE;
	}

	void makeOutput() {
		atomic directionInput = FALSE;
	}
	
	uint8_t isInput() {
		atomic return directionInput;
	}

	uint8_t isOutput() {
		atomic return !directionInput;
	}

	async command void GeneralIO.set() { set(); }
	async command void GeneralIO.clr() { clear(); }
	async command void GeneralIO.toggle() { toggle(); }
	async command bool GeneralIO.get() { return get(); }
	async command void GeneralIO.makeInput() { makeInput(); }
	async command bool GeneralIO.isInput() { return isInput(); }
	async command void GeneralIO.makeOutput() { makeOutput(); }
	async command bool GeneralIO.isOutput() { return isOutput(); }
	async command void GeneralIO.pullup() { set(); }
	async command void GeneralIO.pulldown() { clear(); }
	async command void GeneralIO.highZ() { makeInput(); }

	async command error_t GpioInterrupt.enableRisingEdge() { return SUCCESS; }
	async command error_t GpioInterrupt.enableFallingEdge() { return SUCCESS; }
	async command error_t GpioInterrupt.disable() { return SUCCESS; }
	
	async command void HplMsp430GeneralIO.set() { set(); }
	async command void HplMsp430GeneralIO.clr() { clear(); }
	async command void HplMsp430GeneralIO.toggle() { toggle(); }
	async command uint8_t HplMsp430GeneralIO.getRaw() { // return value as if whole port had value of this IO pin
		atomic return value ? 255 : 0;
	}
	async command bool HplMsp430GeneralIO.get() { return get(); }
	async command void HplMsp430GeneralIO.makeInput() { makeInput(); }
	async command bool HplMsp430GeneralIO.isInput() { return isInput(); }
	async command void HplMsp430GeneralIO.makeOutput() { makeOutput(); }
	async command bool HplMsp430GeneralIO.isOutput() { return isOutput(); }
	async command void HplMsp430GeneralIO.selectModuleFunc() {}
	async command bool HplMsp430GeneralIO.isModuleFunc() { return FALSE; }
	async command void HplMsp430GeneralIO.selectIOFunc() {}
	async command bool HplMsp430GeneralIO.isIOFunc() { return TRUE; }
	
	async command void HplMsp430Interrupt.enable() {}
	async command void HplMsp430Interrupt.disable() {}
	async command void HplMsp430Interrupt.clear() {}
	async command void HplMsp430Interrupt.edge(bool low_to_high) {}
	async command bool HplMsp430Interrupt.getValue() { return get(); }
	
	async command error_t HplMsp430GeneralIO.setResistor(uint8_t mode) { return SUCCESS; }
	async command uint8_t HplMsp430GeneralIO.getResistor() { return MSP430_PORT_RESISTOR_OFF; }
	
}
