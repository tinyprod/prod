/**
 * Provides synchronous acknowledgements.
 * Must be wired into the stack below LowPowerListening.
 */ 
configuration AckC {
	provides {
		interface StdControl;
		interface Send;
		interface Receive;
		interface PacketAcknowledgements;
	}
	
	uses {
		interface StdControl as SubControl;
		interface Send as SubSend;
		interface Receive as SubReceive;
	}
}

implementation {
	
	components AckP, ChipconPacketC, new TimerMilliC();
	
	StdControl = AckP;
	Receive = AckP;
	Send = AckP;
	PacketAcknowledgements = ChipconPacketC;
	
	AckP.SubSend = SubSend;
	AckP.SubReceive = SubReceive;
	AckP.SubControl = SubControl;

	AckP.Packet -> ChipconPacketC;
	AckP.AMPacket -> ChipconPacketC;
	AckP.ChipconPacket -> ChipconPacketC;
	AckP.AckTimer -> TimerMilliC;
	
}
