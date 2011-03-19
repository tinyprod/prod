#include "UserButton.h"

module ButtonC
{
  uses interface Leds;
  uses interface Boot;
  uses interface Notify<button_state_t> as Button;
}
implementation
{
  event void Boot.booted()
  {
	call Button.enable();
  }

  event void Button.notify(button_state_t val) {
  	if(val == BUTTON_RELEASED) {
		call Leds.led0Off();
	} else {
		call Leds.led0On();
	}
  }
  
}