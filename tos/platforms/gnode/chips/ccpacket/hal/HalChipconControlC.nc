#include "AM.h"
#include "HalChipconControl.h"

/**
 * Radio control and configuration.
 */
configuration HalChipconControlC {
	provides {
		interface HalChipconControl;
		interface Get<cc_hal_status_t*> as Status;
	}
}

implementation {
	
	components MainC, BusyWaitMicroC, ActiveMessageAddressC, LocalTime32khzC;
	components HalChipconControlP, HplChipconPacketRadioC, new TimerMilliC();

	HalChipconControl =  HalChipconControlP;
	Status =  HalChipconControlP;
	
	MainC.SoftwareInit -> HalChipconControlP;

	HalChipconControlP.ActiveMessageAddress -> ActiveMessageAddressC;
	HalChipconControlP.BusyWait -> BusyWaitMicroC;
	HalChipconControlP.SpiResource-> HplChipconPacketRadioC;
	HalChipconControlP.HplChipconSpi -> HplChipconPacketRadioC;
	HalChipconControlP.SI -> HplChipconPacketRadioC.SI;
	HalChipconControlP.SO -> HplChipconPacketRadioC.SO;
	HalChipconControlP.Clock -> HplChipconPacketRadioC.Clock;
	HalChipconControlP.CSn -> HplChipconPacketRadioC.CSn;
	HalChipconControlP.G0 -> HplChipconPacketRadioC.G0;
	HalChipconControlP.G2 -> HplChipconPacketRadioC.G2;
	HalChipconControlP.G0Interrupt -> HplChipconPacketRadioC.G0Interrupt;
	HalChipconControlP.TxTimer -> TimerMilliC;
	HalChipconControlP.LocalTime -> LocalTime32khzC;
}
