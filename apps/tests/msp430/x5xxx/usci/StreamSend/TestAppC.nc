configuration TestAppC {
} implementation {
  components TestP;

  components MainC;
  TestP.Boot -> MainC;

  components LedsC;
  TestP.Leds -> LedsC;

  components SerialPrintfC;

  components PlatformSerialC;
  TestP.UartStream -> PlatformSerialC;


}

