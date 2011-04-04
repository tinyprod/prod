configuration TestC {
}
implementation {
  components MainC, TestP as App;
  App -> MainC.Boot;

  components HplMsp430UsciA0C as UsciC;
  App.Usci -> UsciC;
  App.Interrupt -> UsciC;
}
