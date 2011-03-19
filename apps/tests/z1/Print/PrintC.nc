#include "printfZ1.h"

module PrintC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as TimerPrint;
}
implementation
{
  uint8_t counter; 

  event void Boot.booted()
  {
	printfz1_init();
	counter = 0;
	call TimerPrint.startPeriodic( 1024 );
  }

  event void TimerPrint.fired()
  {
    call Leds.led0Toggle();
    printfz1("Print num: %d\n", counter);
    counter++;
  }
  
}