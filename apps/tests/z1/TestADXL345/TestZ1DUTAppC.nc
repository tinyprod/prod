 
#include "PrintfUART.h"

configuration TestZ1DUTAppC {}
implementation {
  components MainC, TestZ1DUTC as App, LedsC;
  App.Leds -> LedsC;
  App.Boot -> MainC.Boot;
  components new TimerMilliC() as TestTimer;
  App.TestTimer -> TestTimer;
  
  components new ADXL345C();
  App.Zaxis -> ADXL345C.Z;
  App.AccelControl -> ADXL345C.SplitControl;
}


