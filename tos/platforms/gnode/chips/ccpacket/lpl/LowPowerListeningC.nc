#include "LowPowerListening.h"

/**
 * Provides duty cycling/low power listening.
 */
configuration LowPowerListeningC {
	provides {
		interface StdControl;
		interface Send;
		interface Receive;
		interface LowPowerListening;
	}
	
	uses {
		interface StdControl as SubControl;
		interface Send as SubSend;
		interface Receive as SubReceive;
	}
}

implementation {
	
	components LowPowerListeningP, HalChipconControlC, ChipconPacketC, BusyWaitMicroC;
	components new TimerMilliC() as DutyCycleTimer, new TimerMilliC() as CcaSampleTimer, new TimerMilliC() as ReceiveTimer;
	
	LowPowerListeningP.DutyCycleTimer -> DutyCycleTimer;
	LowPowerListeningP.CcaSampleTimer -> CcaSampleTimer;
	LowPowerListeningP.ReceiveTimer -> ReceiveTimer;
	LowPowerListeningP.BusyWait -> BusyWaitMicroC;
	LowPowerListeningP.HalChipconControl -> HalChipconControlC;
	LowPowerListeningP.ChipconPacket -> ChipconPacketC;
	
	LowPowerListeningP.SubControl = SubControl;
	LowPowerListeningP.SubSend = SubSend;
	LowPowerListeningP.SubReceive = SubReceive;
	
	StdControl = LowPowerListeningP;
	Receive = LowPowerListeningP;
	Send = LowPowerListeningP;
	LowPowerListening = LowPowerListeningP;
	
}
