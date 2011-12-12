#include "PacketTimeSync.h"

configuration ChipconTimeSyncMessageC {
	provides {
		interface StdControl;
		interface SplitControl;
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface LowPowerListening;
		interface PacketAcknowledgements;

		interface TimeSyncAMSend<TMilli, uint32_t> as TimeSyncAMSendMilli[am_id_t];
		interface TimeSyncPacket<TMilli, uint32_t> as TimeSyncPacketMilli;
		interface PacketTimeStamp<TMilli, uint32_t>  as PacketTimeStampMilli;
		
		interface TimeSyncAMSend<T32khz, uint32_t> as TimeSyncAMSend32khz[am_id_t] ;
		interface TimeSyncPacket<T32khz, uint32_t> as TimeSyncPacket32khz;
		interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;
	}
}

implementation {
	
	components PacketTimeSyncC, PacketTimeStampC, ActiveMessageC;
	
	StdControl = ActiveMessageC;
	SplitControl = ActiveMessageC;
	LowPowerListening = ActiveMessageC;
	PacketAcknowledgements = ActiveMessageC;
	
	PacketTimeStampMilli = PacketTimeStampC;
	PacketTimeStamp32khz = PacketTimeStampC;
		
	TimeSyncAMSendMilli = PacketTimeSyncC;
	TimeSyncPacketMilli = PacketTimeSyncC;
	
	TimeSyncAMSend32khz = PacketTimeSyncC;
	TimeSyncPacket32khz = PacketTimeSyncC;
	
	Receive = PacketTimeSyncC.Receive;
	Snoop = PacketTimeSyncC.Snoop;
	AMPacket = PacketTimeSyncC;
	Packet = PacketTimeSyncC;
	
	// Only wire AM_TIMESYNCMSG if the application uses TimeSyncMessageC,
	// or it would conflict with apps like BaseStation, which wire all AM types
	// and cause fan-out of the Receive interface, which doesn't work.
	components new AMSenderC(AM_TIMESYNCMSG);
	PacketTimeSyncC.SubSend -> AMSenderC;
	PacketTimeSyncC.SubReceive -> ActiveMessageC.Receive[AM_TIMESYNCMSG];
	PacketTimeSyncC.SubSnoop -> ActiveMessageC.Snoop[AM_TIMESYNCMSG];
	
}
