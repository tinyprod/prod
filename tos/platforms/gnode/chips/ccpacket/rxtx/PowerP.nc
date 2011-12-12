module PowerP {
	provides interface StdControl;
	uses interface HalChipconControl;
}

implementation {

	bool on = FALSE;
	
	/**
	 * Power up the radio, go into RX mode, unless the radio
	 * is already on, in which case this does nothing (leaves radio in current state).
	 * @return SUCCESS
	 */
	command error_t StdControl.start() {
		if (!on) {
			call HalChipconControl.on();
			on = TRUE;
		}
		
		return SUCCESS;
	}
	
	/**
	 * Power down the radio if it is not already off.
	 * @return SUCCESS
	 */
	command error_t StdControl.stop() {
		if (on) {
			call HalChipconControl.off();
			on = FALSE;
		}
		
		return SUCCESS;
	}
	
	event void HalChipconControl.txStart(uint32_t timestamp) {}
	event void HalChipconControl.txDone(uint32_t timestamp, error_t error) {}
	event void HalChipconControl.rxWaiting(uint32_t timestamp) {}
}
