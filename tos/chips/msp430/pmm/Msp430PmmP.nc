
#include "Msp430Pmm.h"

/**
 * @author David Moss
 */

module Msp430PmmP {
  provides {
    interface Init;
    interface Pmm;
  }
}

implementation {

  command error_t Init.init() {
    call Pmm.setVoltage(DEFAULT_VCORE_LEVEL);
    return SUCCESS;
  }

  /**
   * Set the voltage level of the MSP430x core
   *  0x0 => DVcc > 1.8V
   *  0x1 => DVcc > 2.0V
   *  0x2 => DVcc > 2.2V
   *  0x3 => DVcc > 2.4V
   *
   * The CC1101 radio core requires 0x2.
   * @param level The voltage level between 0-3
   */

  command void Pmm.setVoltage(uint8_t level) {
    // Open PMM registers for write access
    PMMCTL0_H = 0xA5;
    // Set SVS/SVM high side new level
    SVSMHCTL = SVSHE + SVSHRVL0 * level + SVMHE + SVSMHRRL0 * level;
    // Set SVM low side to new level
    SVSMLCTL = SVSLE + SVMLE + SVSMLRRL0 * level;
    // Wait till SVM is settled
    while ((PMMIFG & SVSMLDLYIFG) == 0);
    // Clear already set flags
    PMMIFG &= ~(SVMLVLRIFG + SVMLIFG);
    // Set VCore to new level
    PMMCTL0_L = PMMCOREV0 * level;
    // Wait till new level reached
    if ((PMMIFG & SVMLIFG))
    while ((PMMIFG & SVMLVLRIFG) == 0);
    // Set SVS/SVM low side to new level
    SVSMLCTL = SVSLE + SVSLRVL0 * level + SVMLE + SVSMLRRL0 * level;
    // Lock PMM registers for write access
    PMMCTL0_H = 0x00;
  }
}
