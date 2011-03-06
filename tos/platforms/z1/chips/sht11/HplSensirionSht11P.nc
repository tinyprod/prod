
#include "Timer.h"

/**
 * HplSensirionSht11P is a low-level component that controls power for
 * the Sensirion SHT11 sensor on the telosb platform.
 */

module HplSensirionSht11P {
  provides interface SplitControl;
  uses interface Timer<TMilli>;
  uses interface GeneralIO as PWR;
  uses interface GeneralIO as DATA;
  uses interface GeneralIO as SCK;
}
implementation {
  task void stopTask();

  command error_t SplitControl.start() {
    call PWR.makeOutput();
    call PWR.set();
    call Timer.startOneShot( 11 );
    return SUCCESS;
  }
  
  event void Timer.fired() {
    signal SplitControl.startDone( SUCCESS );
  }

  command error_t SplitControl.stop() {
    call SCK.makeInput();
    call SCK.clr();
    call DATA.makeInput();
    call DATA.clr();
    call PWR.clr();
    post stopTask();
    return SUCCESS;
  }

  task void stopTask() {
    signal SplitControl.stopDone( SUCCESS );
  }
}

