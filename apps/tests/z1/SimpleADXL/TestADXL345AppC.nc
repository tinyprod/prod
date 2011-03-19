// $Id: RadioSenseToLedsAppC.nc,v 1.4 2006/12/12 18:22:49 vlahan Exp $

 

configuration TestADXL345AppC {}
implementation {
  components MainC, TestADXL345C as App, LedsC;
  App.Boot -> MainC.Boot;
  
  App.Leds -> LedsC;
  components new TimerMilliC() as TimerRead;
  App.TimerRead -> TimerRead;

  components ADXL345C;
  App.XAxis -> ADXL345C.X;
  App.YAxis -> ADXL345C.Y;
  App.ZAxis -> ADXL345C.Z;
  App.AccelControl -> ADXL345C;
  App.ADXL345Control -> ADXL345C;
    
}
