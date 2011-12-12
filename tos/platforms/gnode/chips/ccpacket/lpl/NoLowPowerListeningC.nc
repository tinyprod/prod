/**
 * Disables duty cycling/low power listening, although you can still send to a node which duty cycles.
 */
configuration NoLowPowerListeningC {
	provides {
		interface StdControl;
		interface Send;
		interface Receive;
		interface LowPowerListening;
	}
	
	uses {
		interface StdControl as SubControl;
		interface Send as SubSend;
		interface Receive as SubReceive;
	}
}

implementation {
	
#ifdef LPL_DEFAULT_INTERVAL
#warning LPL_DEFAULT_INTERVAL is defined, but LPL is disabled!
#endif
	
	components NoLowPowerListeningP, ChipconPacketC;
	NoLowPowerListeningP.ChipconPacket -> ChipconPacketC;
	
	StdControl = SubControl;
	Receive = SubReceive;
	Send = SubSend;
	LowPowerListening = NoLowPowerListeningP;
	
}
