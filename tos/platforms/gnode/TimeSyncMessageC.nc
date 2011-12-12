#include "PacketTimeSync.h"

configuration TimeSyncMessageC {
	provides {
		interface StdControl;
		interface SplitControl;
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface LowPowerListening;
		interface PacketAcknowledgements;
		
		// explicitly named precisions for FTSP, although TEP 132/133
		// say the TMilli interfaces should have names without suffixes
		interface TimeSyncAMSend<TMilli, uint32_t> as TimeSyncAMSendMilli[am_id_t];
		interface TimeSyncPacket<TMilli, uint32_t> as TimeSyncPacketMilli;
		interface PacketTimeStamp<TMilli, uint32_t>  as PacketTimeStampMilli;
		
		interface TimeSyncAMSend<T32khz, uint32_t> as TimeSyncAMSend32khz[am_id_t] ;
		interface TimeSyncPacket<T32khz, uint32_t> as TimeSyncPacket32khz;
		interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;
	}
}

implementation {
	
	components ChipconTimeSyncMessageC;
	
	StdControl = ChipconTimeSyncMessageC;
	SplitControl = ChipconTimeSyncMessageC;
	Receive = ChipconTimeSyncMessageC.Receive;
	Snoop = ChipconTimeSyncMessageC.Snoop;
	AMPacket = ChipconTimeSyncMessageC;
	Packet = ChipconTimeSyncMessageC;
	LowPowerListening = ChipconTimeSyncMessageC;
	PacketAcknowledgements = ChipconTimeSyncMessageC;
	
	TimeSyncAMSendMilli = ChipconTimeSyncMessageC;
	TimeSyncPacketMilli = ChipconTimeSyncMessageC;
	PacketTimeStampMilli = ChipconTimeSyncMessageC;

	TimeSyncAMSend32khz = ChipconTimeSyncMessageC;
	TimeSyncPacket32khz = ChipconTimeSyncMessageC;
	PacketTimeStamp32khz = ChipconTimeSyncMessageC;
	
}
