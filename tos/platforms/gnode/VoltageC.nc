/**
 * VoltageC wraps Msp430InternalVoltageC and converts the output to millivolts.
 */
generic configuration VoltageC() {
	provides interface Read<uint16_t>;
}

implementation {
	components new Msp430InternalVoltageC(), new VoltageP();
	Read = VoltageP;
	VoltageP.SubRead -> Msp430InternalVoltageC;
}

