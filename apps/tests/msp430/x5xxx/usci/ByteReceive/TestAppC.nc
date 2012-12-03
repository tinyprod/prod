configuration TestAppC {
} implementation {
  components TestP;

  components MainC;
  TestP.Boot -> MainC;

  components LocalTimeMilliC;
  TestP.LocalTime_bms -> LocalTimeMilliC;

  components PlatformSerialC;
  TestP.UartByte -> PlatformSerialC;

  components SerialPrintfC;
}

