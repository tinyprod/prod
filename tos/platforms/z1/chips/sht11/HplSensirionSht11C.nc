
configuration HplSensirionSht11C {
  provides interface Resource[ uint8_t id ];
  provides interface GeneralIO as DATA;
  provides interface GeneralIO as SCK;
  provides interface GpioInterrupt as InterruptDATA;
}
implementation {
  components HplMsp430GeneralIOC;
  
  components new Msp430GpioC() as DATAM;
  components new Msp430GpioC() as SCKM;
  components new Msp430GpioC() as PWRM;

  DATAM -> HplMsp430GeneralIOC.Port10;
  SCKM -> HplMsp430GeneralIOC.Port16;
  PWRM -> HplMsp430GeneralIOC.Port21;

  DATA = DATAM;
  SCK = SCKM;

  components HplSensirionSht11P;
  HplSensirionSht11P.PWR -> PWRM;
  HplSensirionSht11P.DATA -> DATAM;
  HplSensirionSht11P.SCK -> SCKM;

  components new TimerMilliC();
  HplSensirionSht11P.Timer -> TimerMilliC;

  components HplMsp430InterruptC;
  components new Msp430InterruptC() as InterruptDATAC;
  InterruptDATAC.HplInterrupt -> HplMsp430InterruptC.Port10;
  InterruptDATA = InterruptDATAC.Interrupt;

  components new FcfsArbiterC( "Sht11.Resource" ) as Arbiter;
  Resource = Arbiter;
  
  components new SplitControlPowerManagerC();
  SplitControlPowerManagerC.SplitControl -> HplSensirionSht11P;
  SplitControlPowerManagerC.ArbiterInfo -> Arbiter.ArbiterInfo;
  SplitControlPowerManagerC.ResourceDefaultOwner -> Arbiter.ResourceDefaultOwner;
}
