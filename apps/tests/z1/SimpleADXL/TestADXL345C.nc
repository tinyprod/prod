 
#include "Timer.h"
#include "PrintfUART.h"
#include "ADXL345.h"

module TestADXL345C {
  uses {
    interface Leds;
    interface Boot;
    interface Timer<TMilli> as TimerRead;
    interface Read<uint16_t> as XAxis;
    interface Read<uint16_t> as YAxis;
    interface Read<uint16_t> as ZAxis;
    interface SplitControl as AccelControl;
    interface ADXL345Control;
  }
}
implementation {

  int16_t x, y, z;

  event void Boot.booted() {
    call Leds.led0On();
	printfUART_init();
	printfUART("Booted\n");
	call AccelControl.start();
  }

  event void AccelControl.startDone(error_t error){
    printfUART("Accel ON\n");
    call Leds.led1On();
  	call ADXL345Control.setRange(ADXL345_RANGE_4G, ADXL345_FULLRES);
  }
  
  event void AccelControl.stopDone(error_t error){
  
  }
  
  event void ADXL345Control.setRangeDone(){
    printfUART("done \n");
  	call TimerRead.startPeriodic(1000);
  }
  
  event void TimerRead.fired(){
   	call XAxis.read();
  }

  event void XAxis.readDone(error_t error, uint16_t data){
	//call Leds.led2Toggle();
	x = data;
  	printfUART("X %d ", x);
  	//printfUART("X %d \n", x);
  	call YAxis.read();
  }
  
  event void YAxis.readDone(error_t error, uint16_t data){
	//call Leds.led2Toggle();
	y = data;
  	printfUART("\tY %d", y);
  	call ZAxis.read();
  }
  
  event void ZAxis.readDone(error_t error, uint16_t data){
	call Leds.led2Toggle();
	z = data;
  	printfUART("\tZ %d\n", z);
  }
  
    
   
}
