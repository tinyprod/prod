#include "PacketTimeSync.h"

configuration PacketTimeSyncC {
	provides {
		interface TimeSyncAMSend<TMilli, uint32_t> as TimeSyncAMSendMilli[am_id_t];
		interface TimeSyncPacket<TMilli, uint32_t> as TimeSyncPacketMilli;
		
		interface TimeSyncAMSend<T32khz, uint32_t> as TimeSyncAMSend32khz[am_id_t] ;
		interface TimeSyncPacket<T32khz, uint32_t> as TimeSyncPacket32khz;
		
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
	}
	
	uses {
		interface AMSend as SubSend;
		interface Receive as SubReceive;
		interface Receive as SubSnoop;
	}
}

implementation {
	
	components PacketTimeSyncP, PacketTimeStampC;
	
	Receive = PacketTimeSyncP.Receive;
	Snoop = PacketTimeSyncP.Snoop;
	AMPacket = PacketTimeSyncP;
	Packet = PacketTimeSyncP;
	
	SubSend = PacketTimeSyncP.SubSend;
	SubReceive = PacketTimeSyncP.SubReceive;
	SubSnoop = PacketTimeSyncP.SubSnoop;
	
	TimeSyncAMSendMilli = PacketTimeSyncP;
	TimeSyncPacketMilli = PacketTimeSyncP;
	
	TimeSyncAMSend32khz = PacketTimeSyncP;
	TimeSyncPacket32khz = PacketTimeSyncP;
	
	components ActiveMessageC, SendReceiveC, LocalTimeMilliC, LocalTime32khzC;
	PacketTimeSyncP.SubAMPacket -> ActiveMessageC;
	PacketTimeSyncP.SubPacket -> ActiveMessageC;
	PacketTimeSyncP.PacketTimeStamp32khz -> PacketTimeStampC;
	PacketTimeSyncP.SendNotify -> SendReceiveC;
	PacketTimeSyncP.LocalTimeMilli -> LocalTimeMilliC;
	PacketTimeSyncP.LocalTime32khz -> LocalTime32khzC;
	
}
