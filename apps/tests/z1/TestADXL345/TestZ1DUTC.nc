 
// #include "Timer.h"
#include "PrintfUART.h"

module TestZ1DUTC {
  uses {
    interface Leds;
    interface Boot;
    interface Timer<TMilli> as TestTimer;	
    interface Read<uint16_t> as Zaxis;
    interface SplitControl as AccelControl;
  }
}
implementation {  
  void printTitles(){
    printfUART("\n\n");
  	printfUART("   ###############################\n");
  	printfUART("   #       Z1 DUT MOTE v1.0      #\n");
  	printfUART("   ###############################\n");
  	printfUART("\n");
  }

  event void Boot.booted() {
    printfUART_init();
	printTitles();
	call TestTimer.startPeriodic(1024);
  }
  
  event void TestTimer.fired(){
    call AccelControl.start();
  }

   event void AccelControl.startDone(error_t err) {
    if (err == SUCCESS){
  	  call Zaxis.read();
	}
  }
  
  event void AccelControl.stopDone(error_t err) {}
  
  event void Zaxis.readDone(error_t result, uint16_t data){
    if (result == SUCCESS){
	  call Leds.led2Toggle();
	 printfUART("Zaxis: %d\n", data);     
    }
  }

  
}





