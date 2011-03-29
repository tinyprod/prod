configuration SerialDirectC {}
implementation {
  components SerialDirectP as App, MainC;
  App.Boot -> MainC.Boot;

#ifdef USE_X1
  components HplMsp430Usart0C as Port;
#else
  components HplMsp430UsciA0C as Port;
#endif
  App.Port -> Port;
  App.PortInt -> Port;
}
