/**
 * Disables duty cycling/low power listening, although you can still send to a node which duty cycles.
 */
module NoLowPowerListeningP {
	provides {
		interface LowPowerListening;
	}
	
	uses {
		interface ChipconPacket;
	}
}

implementation {
	
	command void LowPowerListening.setLocalWakeupInterval(uint16_t sleepIntervalMs) {}
	
	/**
	 * @return the local node's sleep interval, in milliseconds
	 */
	command uint16_t LowPowerListening.getLocalWakeupInterval() {
		return 0;
	}
	
	/**
	 * Configure this outgoing message so it can be transmitted to a neighbor mote
	 * with the specified Rx sleep interval.
	 * @param msg Pointer to the message that will be sent
	 * @param sleepInterval The receiving node's sleep interval, in milliseconds
	 */
	command void LowPowerListening.setRemoteWakeupInterval(message_t *msg, uint16_t sleepIntervalMs) {
		(call ChipconPacket.getMetadata(msg))->rxInterval = sleepIntervalMs;
	}
	
	/**
	 * @return the destination node's sleep interval configured in this message
	 */
	command uint16_t LowPowerListening.getRemoteWakeupInterval(message_t *msg) {
		return (call ChipconPacket.getMetadata(msg))->rxInterval;
	}
	
}
