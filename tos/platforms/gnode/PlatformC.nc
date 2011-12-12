#include "hardware.h"

 // some TinyOS apps don't include this,
// instead depending on the platform to do it for them
#include "AM.h"

configuration PlatformC {
	provides interface Init;
}

implementation {

#ifndef assert
	components AssertRebootC;
#endif

	components PlatformP, PlatformClockC, PlatformPinsC, StackGuardWatchDogC;

	Init = PlatformP;
	PlatformP.InitLevel[0] -> PlatformClockC;		// setup clocks
	PlatformP.InitLevel[1] -> PlatformPinsC;		// configure I/O pins
	PlatformP.InitLevel[2] -> StackGuardWatchDogC;	// init stack protection and start watchdog

}
