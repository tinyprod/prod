configuration AccelerometerAppC
{
}
implementation
{
  components MainC, AccelerometerC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components new TimerMilliC() as TimerAccel;
  App.TimerAccel -> TimerAccel;
  
  components new ADXL345C();
  App.Zaxis -> ADXL345C.Z;
  App.Yaxis -> ADXL345C.Y;
  App.Xaxis -> ADXL345C.X;
  App.AccelControl -> ADXL345C.SplitControl;
}