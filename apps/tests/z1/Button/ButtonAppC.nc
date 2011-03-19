configuration ButtonAppC
{
}
implementation
{
  components MainC, ButtonC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components UserButtonC;
  App.Button -> UserButtonC;

}