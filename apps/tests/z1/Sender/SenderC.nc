#include "Timer.h"
#include "Wireless.h"
 
module SenderC {
   uses interface Leds;
   uses interface Boot;
   uses interface AMSend;
   uses interface Timer<TMilli> as TimerWireless;
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
      call TimerWireless.startPeriodic(250);
    }
    else {
      call AMControl.start();
    }
  }
 
  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
 
  event void TimerWireless.fired() {
    counter++;
    if (locked) {
      return;
    }
    else {
      wireless_msg_t* rcm = (wireless_msg_t*)call Packet.getPayload(&packet, sizeof(wireless_msg_t));
      if (rcm == NULL) {
	return;
      }
 
      rcm->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(wireless_msg_t)) == SUCCESS) {
	locked = TRUE;
      }
    }
  }
 
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
 
}