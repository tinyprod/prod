configuration BlinkAppC
{
}
implementation
{
  components MainC, BlinkC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components new TimerMilliC() as TimerBlink;
  App.TimerBlink -> TimerBlink;
}