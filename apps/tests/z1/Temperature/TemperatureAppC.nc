configuration TemperatureAppC
{
}
implementation
{
  components MainC, TemperatureC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components new TimerMilliC() as TimerTemperature;
  App.TimerTemperature -> TimerTemperature;
  
  components new SimpleTMP102C();
  App.Temperature -> SimpleTMP102C;    

}