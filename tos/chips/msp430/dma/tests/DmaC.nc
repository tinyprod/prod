configuration DmaC {}
implementation {
  components DmaP as App, MainC;
  App.Boot -> MainC.Boot;

  components Msp430DmaC;
  App.Dma  -> Msp430DmaC.Control;
  App.Dma0 -> Msp430DmaC.Channel0;
  App.Dma1 -> Msp430DmaC.Channel1;
  App.Dma2 -> Msp430DmaC.Channel2;
}
