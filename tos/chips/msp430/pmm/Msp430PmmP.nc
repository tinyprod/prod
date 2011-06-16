/*
 * Copyright (c) 2011 Eric B. Decker
 * Copyright (c) 2010 People Power Co.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author David Moss
 * @author Eric B. Decker <cire831@gmail.com>
 *
 * This provides a driver for communicating with the Power Management
 * Module provided on X5 family processors.
 *
 * This module should be called from processor initilization to change
 * the VCORE level.   It can also be called at other times if a change
 * to VCORE is needed (like if we need to run at a faster frequency).
 *
 * On x5 processors examined, VCORE_LEVEL in the PMM is initilized to 0.
 * But this should be checked with the processor data sheet.
 */

#if !defined(__MSP430_HAS_PMM__)
#error "Msp430PmmP: processor not supported, need PMM"
#endif

module Msp430PmmP {
  provides interface Pmm;
}
implementation {

  /**
   * Set the voltage level of the MSP430x core
   *  0x0 => DVcc > 1.8V
   *  0x1 => DVcc > 2.0V
   *  0x2 => DVcc > 2.2V
   *  0x3 => DVcc > 2.4V
   */

  command void Pmm.setVoltage(uint8_t level) {

    // Open PMM registers for write access
    PMMCTL0_H = 0xA5;

    // Set SVS/SVM high side new level
    SVSMHCTL = SVSHE + SVSHRVL0 * level + SVMHE + SVSMHRRL0 * level;

    // Set SVM low side to new level
    SVSMLCTL = SVSLE + SVMLE + SVSMLRRL0 * level;

    // Wait till SVM is settled
    while ((PMMIFG & SVSMLDLYIFG) == 0) {
    }

    // Clear already set flags
    PMMIFG &= ~(SVMLVLRIFG + SVMLIFG);

    // Set VCore to new level
    PMMCTL0_L = PMMCOREV0 * level;

    // Wait till new level reached
    if ((PMMIFG & SVMLIFG))
      while ((PMMIFG & SVMLVLRIFG) == 0) {
      }

    // Set SVS/SVM low side to new level
    SVSMLCTL = SVSLE + SVSLRVL0 * level + SVMLE + SVSMLRRL0 * level;

    // Lock PMM registers for write access
    PMMCTL0_H = 0x00;
  }
}
