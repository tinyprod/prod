#include "AM.h"
#include "ChipconAssert.h"

// the radio stack uses platform_printf debug statements which can be redirected to printf,
// but the default is to turn them into no-ops
#ifndef platform_printf
#define platform_printf(...);
#endif

/**
 * The Active Message layer for the Chipcon packet radio.
 * In addition to the required SplitControl, it also offers StdControl.
 */
configuration ChipconActiveMessageC {
	provides {
		interface StdControl;
		interface SplitControl;
		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface LowPowerListening;
		interface PacketAcknowledgements;
		interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
		interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;
	}
}

implementation {
	components ActiveMessageAddressC, ChipconPacketC, PacketMetadataC, ChipconActiveMessageP as AM, CrcC;
	
	components PacketTimeStampC;

#ifdef LOW_POWER_LISTENING
	components LowPowerListeningC as LPL;
#else
	components NoLowPowerListeningC as LPL;
#endif
	
	components AckC;
	components SendReceiveC;

	StdControl = AM;
	SplitControl = AM;
	AMSend = AM;
	Receive = AM.Receive;
	Snoop = AM.Snoop;
	
	Packet = ChipconPacketC;
	AMPacket = ChipconPacketC;
	PacketAcknowledgements = ChipconPacketC;
	LowPowerListening = LPL;
	PacketTimeStampMilli = PacketTimeStampC;
	PacketTimeStamp32khz = PacketTimeStampC;
	
	AM.AMPacket -> ChipconPacketC;
	AM.PacketMetadata -> PacketMetadataC;
	AM.SubControl -> LPL;
	AM.SubSend -> LPL;
	AM.SubReceive -> LPL;
	AM.Crc -> CrcC;
	
	LPL.SubControl -> AckC;
	LPL.SubSend -> AckC;
	LPL.SubReceive -> AckC;
	
	AckC.SubControl -> SendReceiveC;
	AckC.SubSend -> SendReceiveC;
	AckC.SubReceive -> SendReceiveC;
		
}
