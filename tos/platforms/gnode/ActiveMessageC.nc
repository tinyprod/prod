#include "AM.h"
#include "Timer.h"

/**
 * Wraps/renames ChipconActiveMessageC.
 */
configuration ActiveMessageC {
	provides {
		interface StdControl;
		interface SplitControl;

		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];

		interface Packet;
		interface AMPacket;
		interface PacketAcknowledgements;
		interface LowPowerListening;
		
		interface PacketTimeStamp<TMilli, uint32_t>;
		interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;
	}
}

implementation {
	
	components ChipconActiveMessageC as AM;
	
	StdControl = AM;
	SplitControl = AM;
	AMSend = AM;
	Receive = AM.Receive;
	Snoop = AM.Snoop;
	Packet = AM;
	AMPacket = AM;
	PacketAcknowledgements = AM;
	LowPowerListening = AM;
	PacketTimeStamp = AM;
	PacketTimeStamp32khz = AM;
	
}
