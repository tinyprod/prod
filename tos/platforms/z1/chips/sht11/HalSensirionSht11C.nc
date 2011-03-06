
configuration HalSensirionSht11C {
  provides interface Resource[ uint8_t client ];
  provides interface SensirionSht11[ uint8_t client ];
}
implementation {
  components new SensirionSht11LogicP();
  SensirionSht11 = SensirionSht11LogicP;

  components HplSensirionSht11C;
  Resource = HplSensirionSht11C.Resource;
  SensirionSht11LogicP.DATA -> HplSensirionSht11C.DATA;
  SensirionSht11LogicP.CLOCK -> HplSensirionSht11C.SCK;
  SensirionSht11LogicP.InterruptDATA -> HplSensirionSht11C.InterruptDATA;
  
  components new TimerMilliC();
  SensirionSht11LogicP.Timer -> TimerMilliC;

  components LedsC;
  SensirionSht11LogicP.Leds -> LedsC;
}
