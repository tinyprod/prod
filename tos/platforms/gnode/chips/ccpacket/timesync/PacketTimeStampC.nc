#include "PacketTimeSync.h"

/**
 * Handles conversion of 32 kHz timestamps to TMilli timestamps.
 * Also wires through the 32 kHz version to have a single point of access.
 */
configuration PacketTimeStampC {
	provides {
		interface PacketTimeStamp<TMilli, uint32_t>  as PacketTimeStampMilli;
		interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;
	}
}

implementation {
	
	components PacketTimeStampP, ChipconPacketC;
	
	PacketTimeStampMilli = PacketTimeStampP;
	PacketTimeStamp32khz = ChipconPacketC;
	
	components LocalTimeMilliC, LocalTime32khzC;
	PacketTimeStampP.PacketTimeStamp32khz -> ChipconPacketC;
	PacketTimeStampP.LocalTimeMilli -> LocalTimeMilliC;
	PacketTimeStampP.LocalTime32khz -> LocalTime32khzC;
	
}
