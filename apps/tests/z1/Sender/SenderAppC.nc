#include "Wireless.h"
 
configuration SenderAppC {}
implementation {
  components SenderC as App;
 
  components MainC;
  App.Boot -> MainC.Boot;
 
  components LedsC;
  App.Leds -> LedsC;
 
 
  components new AMSenderC(AM_WIRELESS_MSG);
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
 
  components new TimerMilliC();
  App.TimerWireless -> TimerMilliC;
 
  components ActiveMessageC;
  App.AMControl -> ActiveMessageC;
 
}