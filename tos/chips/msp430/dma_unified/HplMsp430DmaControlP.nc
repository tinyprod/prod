/*
 * Copyright (c) 2011 Eric B. Decker
 * Copyright (c) 2005-2006 Arch Rock Corporation
 * Copyright (c) 2000-2005 The Regents of the University of California.  
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
 *
 * @author Ben Greenstein <ben@cs.ucla.edu>
 * @author Jonathan Hui <jhui@archrock.com>
 * @author Joe Polastre <info@moteiv.com>
 * @author Xavier Orduna <xorduna@dexmatech.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#include "Msp430Dma.h"

#if !defined(__MSP430_HAS_DMA_3__) && !defined(__MSP430_HAS_DMAX_3__)
#error "HplMsp430DmaP: processor not supported, need DMA_3 or DMAX_3"
#endif

/*
 * The x1 family shares the DMA and DAC interrupt vector.   Strange.
 * While the x2 has a dedicated interrupt vector.
 */
#if defined(DACDMA_VECTOR)
#define XX_DMA_VECTOR_XX DACDMA_VECTOR
#elif defined(DMA_VECTOR)
#define XX_DMA_VECTOR_XX DMA_VECTOR
#else
#error "DMA VECTOR not defined for cpu selected"
#endif

module HplMsp430DmaControlP {
  provides interface HplMsp430DmaControl as DmaControl;
  provides interface HplMsp430DmaInterrupt as DmaInterrupt[uint8_t chnl];
}

implementation {

  MSP430REG_NORACE(DMA0CTL);
  MSP430REG_NORACE(DMA1CTL);
  MSP430REG_NORACE(DMA2CTL);
  
#ifdef TSELW_1
  /*
   * X5, DMA_OP_CTRL (DMACTL4), TSELW_0 (DMACTL0), TSELW_1 (DMACTL1)
   */
  MSP430REG_NORACE(DMACTL0);
  MSP430REG_NORACE(DMACTL1);
  MSP430REG_NORACE(DMACTL4);
#else
  /*
   * x1/2, DMA_OP_CTRL (DMACTL1), TSELW_0 (DMACTL0)
   */
  MSP430REG_NORACE(DMACTL0);
  MSP430REG_NORACE(DMACTL1);
#endif

  async command void DmaControl.setOpControl(uint16_t op) {
    DMA_OP_CTRL = op;
  }

  async command uint16_t DmaControl.getOpControl() {
    return DMA_OP_CTRL;
  }

  async command void DmaControl.reset(){
    DMA_OP_CTRL = 0;
    TSELW_0 = 0;
#ifdef TSELW_1
    TSELW_1 = 0;
#endif
    DMA0CTL = 0;
    DMA1CTL = 0;
    DMA2CTL = 0;
  }


  /*
   * some processors have a DMAIV, interrupt vector that
   * can be used for accessing a jump table.   But we don't
   * have a jump table and the code here turns out to be more
   * efficient because we know there are only 3 possible and
   * we wire directly into the DmaInterrupt.fired[x].
   */
  TOSH_SIGNAL(XX_DMA_VECTOR_XX) {
    if ((DMA0CTL & DMAIFG) && (DMA0CTL & DMAIE))
      signal DmaInterrupt.fired[0]();
    else if ((DMA1CTL & DMAIFG) && (DMA1CTL & DMAIE))
      signal DmaInterrupt.fired[1]();
    else if ((DMA2CTL & DMAIFG) && (DMA2CTL & DMAIE))
      signal DmaInterrupt.fired[2]();
  }

  default async event void DmaInterrupt.fired[uint8_t chnl] () { }
}
