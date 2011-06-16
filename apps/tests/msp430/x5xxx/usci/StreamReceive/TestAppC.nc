configuration TestAppC {
} implementation {
  components TestP;

  components new TimerMilliC() as Periodic;
  TestP.Periodic -> Periodic;

  components MainC;
  TestP.Boot -> MainC;

  components LedsC;
  TestP.Leds -> LedsC;

  components SerialPrintfC;

  components PlatformSerialC;
  TestP.UartStream -> PlatformSerialC;
  TestP.UartByte -> PlatformSerialC;

}

