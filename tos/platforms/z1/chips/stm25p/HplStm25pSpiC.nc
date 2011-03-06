
/**
 * HPL implementation of the Spi bus for a ST M25P chip connected to a
 * TI MSP430.
 *
 * @author Jonathan Hui <jhui@archrock.com>
 * @version $Revision: 1.4 $ $Date: 2006/12/12 18:23:45 $
 */

configuration HplStm25pSpiC {

  provides interface Resource;
  provides interface SpiByte;
  provides interface SpiPacket;

}

implementation {

  components new Msp430SpiB0C() as SpiC;
  Resource = SpiC;
  SpiByte = SpiC;
  SpiPacket = SpiC;

}
