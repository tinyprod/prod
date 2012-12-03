/**
 * Copyright (c) 2010 People Power Co.
 * All rights reserved.
 *
 * This open source code was developed with funding from People Power Company
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
 * Interface to the interrupts of a single RF1A module.  Really
 * belongs in HplMsp430Rf1aIfP, but must define a C-linkage function
 * which is not possible in a generic module.
 *
 * This converts hardware interrupts into client-specific signals of
 * interface-specific events.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module HplMsp430Rf1aInterruptP {
  provides {
    interface Rf1aInterrupts[uint8_t client];
  }
  uses {
    interface ArbiterInfo;
    interface Leds;
  }
} implementation {

  /** Convert the value read from the interrupt vector register into
   * the corresponding bit position in the interrupt words.
   */
  uint8_t ivToBit (uint8_t iv) {
    return (iv >> 1) - 1;
  }

  TOSH_SIGNAL(CC1101_VECTOR) {
    uint16_t coreInterrupt = RF1AIV;
    uint8_t client = call ArbiterInfo.userId();

    /* If the module isn't in use, there's nobody to signal. */
    if (! call ArbiterInfo.inUse()) {
      return;
    }

    /* Full wake-up on return.
     * @todo Really only certain situations require a wakeup.  Provide a
     * mechanism to nodify this level of those situations.
     */
    __bic_SR_register_on_exit(LPM4_bits);

    /* A value of 0 indicates an interface interrupt, which is currently
     * not made available
     */
    if (coreInterrupt) {

#if 0
      /* @TODO@ I have observed a case where IFG5 negative edge correctly
       * received an interrupt, but the state was not reflected in
       * RF1AIN. Ignoring the interrupt resulted in lost data.  The
       * errata may be erroneous.
       */

      /* ERRATA RF1A5: Interrupt may be generated even though FIFO
       * condition does not hold.  Must validate against RF1AIN.
       */
      uint16_t ifg_bit = 1 << ((coreInterrupt >> 1) - 1);
//      RF1AIFG &= ~ ifg_bit;
      if ((RF1AIV_RFIFG3 <= coreInterrupt)
          && (coreInterrupt <= RF1AIV_RFIFG10)
          && (! (ifg_bit & RF1AIN))) {
        return;
      }
#endif

      switch (coreInterrupt) {
        default:
          signal Rf1aInterrupts.coreInterrupt[client](coreInterrupt);
          break;
        case RF1AIV_RFIFG4:
          signal Rf1aInterrupts.rxFifoAvailable[client]();
          break;
        case RF1AIV_RFIFG5:
          signal Rf1aInterrupts.txFifoAvailable[client]();
          break;
        case RF1AIV_RFIFG7:
          signal Rf1aInterrupts.rxOverflow[client]();
          break;
        case RF1AIV_RFIFG8:
          signal Rf1aInterrupts.txUnderflow[client]();
          break;
        case RF1AIV_RFIFG9:
          signal Rf1aInterrupts.syncWordEvent[client]();
          break;
        case RF1AIV_RFIFG12:
          signal Rf1aInterrupts.clearChannel[client]();
          break;
        case RF1AIV_RFIFG13:
          signal Rf1aInterrupts.carrierSense[client]();
          break;
      }
    }
  }

  default async event void Rf1aInterrupts.rxFifoAvailable[uint8_t client] () { }
  default async event void Rf1aInterrupts.txFifoAvailable[uint8_t client] () { }
  default async event void Rf1aInterrupts.rxOverflow[uint8_t client]      () { }
  default async event void Rf1aInterrupts.txUnderflow[uint8_t client]     () { }
  default async event void Rf1aInterrupts.syncWordEvent[uint8_t client]   () { }
  default async event void Rf1aInterrupts.clearChannel[uint8_t client]    () { }
  default async event void Rf1aInterrupts.carrierSense[uint8_t client]    () { }
  default async event void Rf1aInterrupts.coreInterrupt[uint8_t client] (uint16_t iv) { }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
