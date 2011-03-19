#include "printfZ1.h"

module AccelerometerC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as TimerAccel;
  uses interface Read<uint16_t> as Zaxis;  
  uses interface Read<uint16_t> as Yaxis;  
  uses interface Read<uint16_t> as Xaxis;  
  uses interface SplitControl as AccelControl;  

}
implementation
{
  event void Boot.booted()
  {
	printfz1_init();
	call AccelControl.start();
  }

  event void TimerAccel.fired()
  {
    call Leds.led0Toggle();
    call Xaxis.read();
  }

  event void AccelControl.startDone(error_t err) {
  	printfz1("  +  Accelerometer Started\n");
    call TimerAccel.startPeriodic( 1000 );
  }
  
  event void AccelControl.stopDone(error_t err) {
  	
  }
  
  event void Xaxis.readDone(error_t result, uint16_t data){
  	printfz1("  +  X (%d) ", data);
    call Yaxis.read();
  }
      
  event void Yaxis.readDone(error_t result, uint16_t data){
  	printfz1(" Y (%d) ", data);
    call Zaxis.read();
  }
      
  event void Zaxis.readDone(error_t result, uint16_t data){
  	printfz1(" Z (%d) \n", data);
  }
      
}