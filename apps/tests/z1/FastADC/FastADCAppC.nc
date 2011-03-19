#include "StorageVolumes.h"

configuration FastADCAppC
{
}
implementation
{
  components MainC, FastADCC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components new TimerMilliC() as TimerBlink;
  App.TimerBlink -> TimerBlink;
  components new TimerMilliC() as TimerSample;
  App.TimerSample -> TimerSample;
  
  components new Msp430Adc12ClientAutoDMAC() as Fadc;
  App.overflow -> Fadc;
  App.adc -> Fadc;
  App.Resource -> Fadc;
  
  components new BlockStorageC(VOLUME_BLOCKTEST);
  App.BlockWrite -> BlockStorageC.BlockWrite;
  App.BlockRead -> BlockStorageC.BlockRead;  
  
}