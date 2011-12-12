/**
 * Wire up Send, Receive and Power modules to provide a minimal HIL stack.
 */ 
configuration SendReceiveC {
	provides {
		interface StdControl;
		interface Receive;
		interface Send;
		interface SendNotify;
	}
}

implementation {
	
	components HalChipconControlC, ChipconPacketC;
	
	components SendP, RandomC, new TimerMilliC() as BackoffTimer, new TimerMilliC() as PreambleTimer;
	SendP.Random -> RandomC;
	SendP.BackoffTimer -> BackoffTimer;
	SendP.PreambleTimer -> PreambleTimer;
	SendP.ChipconPacket -> ChipconPacketC;
	SendP.PacketTimeStamp -> ChipconPacketC;
	SendP.HalChipconControl -> HalChipconControlC;
	
	components ReceiveP;
	ReceiveP.Packet -> ChipconPacketC;
	ReceiveP.ChipconPacket -> ChipconPacketC;
	ReceiveP.PacketTimeStamp -> ChipconPacketC;
	ReceiveP.HalChipconControl -> HalChipconControlC;
	
	components PowerP;
	PowerP.HalChipconControl -> HalChipconControlC;
	
	components SendReceiveP;
	SendReceiveP.SubControl -> PowerP;
	SendReceiveP.SubControl -> SendP;
	SendReceiveP.SubSend -> SendP;
	SendReceiveP.SubReceive -> ReceiveP;
	SendReceiveP.ChipconPacket -> ChipconPacketC;
	
	StdControl = SendReceiveP;
	Receive = SendReceiveP;
	Send = SendReceiveP;
	SendNotify = SendP;
	
}
