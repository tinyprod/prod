configuration PacketMetadataC {
	provides {
		interface PacketMetadata;
	}
}

implementation {
	
	components PacketMetadataP, ChipconPacketC;
	PacketMetadata = PacketMetadataP;
	PacketMetadataP.ChipconPacket -> ChipconPacketC;
	
}
