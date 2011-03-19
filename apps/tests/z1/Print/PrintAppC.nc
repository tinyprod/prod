configuration PrintAppC
{
}
implementation
{
  components MainC, PrintC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components new TimerMilliC() as TimerPrint;
  App.TimerPrint -> TimerPrint;

}