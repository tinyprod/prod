#include "printfZ1.h"

module TemperatureC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as TimerTemperature;
  uses interface Read<uint16_t> as Temperature; 
}
implementation
{
  event void Boot.booted()
  {
	printfz1_init();
	call TimerTemperature.startPeriodic( 1024 );
  }

  event void TimerTemperature.fired()
  {
    call Leds.led0Toggle();
    call Temperature.read();
  }

  event void Temperature.readDone(error_t error, uint16_t data){
    printfz1("  +  Temperature (%d)\n", data);
  }  
  
}