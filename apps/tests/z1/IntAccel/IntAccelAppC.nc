configuration IntAccelAppC
{
}
implementation
{
  components MainC, IntAccelC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;
  
  components new ADXL345C();
  App.IntSource -> ADXL345C.IntSource;
  App.AccelControl -> ADXL345C.SplitControl;
  App.IntAccel1 -> ADXL345C.Int1;
  App.IntAccel2 -> ADXL345C.Int2;
  App.ADXLControl -> ADXL345C.ADXL345Control;

}