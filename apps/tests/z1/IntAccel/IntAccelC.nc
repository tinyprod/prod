#include "ADXL345.h"
 
module IntAccelC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Read<uint8_t> as IntSource; 
  uses interface SplitControl as AccelControl;  
  uses interface Notify<adxlint_state_t> as IntAccel1;
  uses interface Notify<adxlint_state_t> as IntAccel2;
  uses interface ADXL345Control as ADXLControl;
 
}
implementation
{
  bool source_int2=FALSE;
 
  event void Boot.booted()
  {
    call AccelControl.start();
  }
 
  event void IntAccel1.notify(adxlint_state_t val) {
	source_int2=FALSE;
	call Leds.led0Toggle();
	call IntSource.read();		//this will clear the interruption
  }
 
  event void IntAccel2.notify(adxlint_state_t val) {
	source_int2=TRUE;
	call IntSource.read();		//this will clear the interruption;
  }
 
  event void AccelControl.startDone(error_t err) {
	call ADXLControl.setInterrups(
		  ADXLINT_DOUBLE_TAP |
		  ADXLINT_SINGLE_TAP | 
		  ADXLINT_FREE_FALL  ); 
  }
 
  event void AccelControl.stopDone(error_t err) {
  }
 
  event void IntSource.readDone(error_t result, uint8_t data){
	if(source_int2) {
	  if(data & ADXLINT_FREE_FALL) call Leds.led2Toggle();
	  else call Leds.led1Toggle();
	}
  }
 
  event void ADXLControl.setInterruptsDone(error_t error){
	call ADXLControl.setIntMap(ADXLINT_DOUBLE_TAP | ADXLINT_FREE_FALL);
  }
 
  event void ADXLControl.setIntMapDone(error_t error){
	call IntAccel1.enable();
	call IntAccel2.enable();
	call IntSource.read();		//this will clear the interruption
  }
 
  event void ADXLControl.setDurationDone(error_t error) { } //not used
 
  event void ADXLControl.setWindowDone(error_t error) { } //not used
 
  event void ADXLControl.setLatentDone(error_t error) { } //not used
 
  event void ADXLControl.setRegisterDone(error_t error) { } //not used
 
  event void ADXLControl.setRangeDone(error_t error) { }  //not used
 
  event void ADXLControl.setReadAddressDone(error_t error) { }  //not used 
 
}