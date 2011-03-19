#include "Wireless.h"
 
module ReceiverC {
   uses interface Leds;
   uses interface Boot;
   uses interface Receive;
   uses interface SplitControl as AMControl;
   uses interface Packet;
}
implementation {
 
  message_t packet;
 
  bool locked;
  uint16_t counter = 0;
 
  event void Boot.booted() {
    call AMControl.start();
  }
 
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      // do nothing
    }
    else {
      call AMControl.start();
    }
  }
 
  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
 
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    if (len != sizeof(wireless_msg_t)) {return bufPtr;}
    else {
      wireless_msg_t* rcm = (wireless_msg_t*)payload;
 
      if (rcm->counter & 0x1) call Leds.led0On();
      else call Leds.led0Off();
 
      if (rcm->counter & 0x2) call Leds.led1On();
      else call Leds.led1Off();
 
      if (rcm->counter & 0x4) call Leds.led2On();
      else call Leds.led2Off();
 
      return bufPtr;
    }
  }
 
}