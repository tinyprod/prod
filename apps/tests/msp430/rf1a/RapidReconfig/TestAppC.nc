configuration TestAppC {
} implementation {
  components TestP;
  components MainC;

  TestP.Boot -> MainC;
  
  components new Rf1aPhysicalC();
  TestP.Rf1aResource -> Rf1aPhysicalC;
  TestP.Rf1aPhysical -> Rf1aPhysicalC;

  components new MuxAlarmMilli16C();
  TestP.Alarm -> MuxAlarmMilli16C;

  components RadioMonitorC;
  components LedC;
  RadioMonitorC.TxActiveLed -> LedC.Green;
  RadioMonitorC.RxActiveLed -> LedC.Red;

  components SerialPrintfC;
}
