configuration ChipconPacketC {
	provides {
		interface ChipconPacket;
		interface Packet;
		interface AMPacket;
		interface PacketAcknowledgements;
		interface PacketTimeStamp<T32khz, uint32_t>;
	}
}

implementation {
	
	components ChipconPacketP, ActiveMessageAddressC;

	ChipconPacket = ChipconPacketP;
	Packet = ChipconPacketP;
	AMPacket = ChipconPacketP;
	PacketAcknowledgements = ChipconPacketP;
	PacketTimeStamp = ChipconPacketP;
	
	ChipconPacketP.ActiveMessageAddress -> ActiveMessageAddressC;
	ChipconPacketP.NetMask -> ActiveMessageAddressC;
	
}
