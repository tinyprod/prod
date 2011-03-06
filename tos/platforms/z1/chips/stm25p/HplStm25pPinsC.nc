
/**
 * HPL implementation of general-purpose I/O for a ST M25P chip
 * connected to a TI MSP430.
 */

configuration HplStm25pPinsC {

  provides interface GeneralIO as CSN;
  provides interface GeneralIO as Hold;

}

implementation {

  components HplMsp430GeneralIOC as HplGeneralIOC;
  components new Msp430GpioC() as CSNM;
  components new Msp430GpioC() as HoldM;

  CSNM -> HplGeneralIOC.Port44;
  HoldM -> HplGeneralIOC.Port57;

  CSN = CSNM;
  Hold = HoldM;

}
