#include "Timer.h"

module BlinkC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as TimerBlink;
}
implementation
{
  event void Boot.booted()
  {
    call TimerBlink.startPeriodic( 250 );
  }

  event void TimerBlink.fired()
  {
    call Leds.led0Toggle();
    call Leds.led1Toggle();
    call Leds.led2Toggle();
  }
  
}