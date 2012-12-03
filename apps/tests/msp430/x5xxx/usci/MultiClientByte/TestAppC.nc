configuration TestAppC {
} implementation {
  components TestP;

  components MainC;
  TestP.Boot -> MainC;

  components LedsC;
  TestP.Leds -> LedsC;

  components new Msp430UsciUartA0C() as Uart1C;
  TestP.Resource1 -> Uart1C;
  TestP.UartByte1 -> Uart1C;

  components new Msp430UsciUartA0C() as Uart2C;
  TestP.Resource2 -> Uart2C;
  TestP.UartByte2 -> Uart2C;

}

