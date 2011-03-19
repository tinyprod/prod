#include "Wireless.h"
 
configuration ReceiverAppC {}
implementation {
  components ReceiverC as App;
 
  components MainC;
  App.Boot -> MainC.Boot;
 
  components LedsC;
  App.Leds -> LedsC;
 
  components new AMReceiverC(AM_WIRELESS_MSG);
  App.Receive -> AMReceiverC;
 
  components ActiveMessageC;
  App.AMControl -> ActiveMessageC;
 
}