
generic configuration SimpleTMP102C() {
  provides interface Read<uint16_t>;
}
implementation {
  components SimpleTMP102P;
  Read = SimpleTMP102P;

  components new TimerMilliC() as TimerSensor;
  SimpleTMP102P.TimerSensor -> TimerSensor;

  components new TimerMilliC() as TimerFail;
  SimpleTMP102P.TimerFail -> TimerFail;

#warning TMP102 using generic wiring (usciB1).   Platform specific wiring is preferred.
  components new Msp430I2CB1C() as I2C;
  SimpleTMP102P.Resource -> I2C;
  SimpleTMP102P.ResourceRequested -> I2C;
  SimpleTMP102P.I2CBasicAddr -> I2C;    
  
}
