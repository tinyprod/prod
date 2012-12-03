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
 * @author Eric B. Decker <cire831@gmail.com>
 */

configuration HplMsp430DmaC {
  provides {
    interface HplMsp430DmaControl as Control;
    interface HplMsp430DmaChannel as Channel0;
    interface HplMsp430DmaChannel as Channel1;
    interface HplMsp430DmaChannel as Channel2;
  }
}

implementation {

  components HplMsp430DmaControlP as ControlP;
  components new
    HplMsp430DmaChannelP(DMA0CTL_, DMA0SA_, DMA0DA_, DMA0SZ_,
			 TSEL0_BASE, TSEL_MASK, TSEL0_SHIFT)
	as Dma0P;

  components new
    HplMsp430DmaChannelP(DMA1CTL_, DMA1SA_, DMA1DA_, DMA1SZ_,
			 TSEL1_BASE, TSEL_MASK, TSEL1_SHIFT)
	as Dma1P;

  components new
    HplMsp430DmaChannelP(DMA2CTL_, DMA2SA_, DMA2DA_, DMA2SZ_,
			 TSEL2_BASE, TSEL_MASK, TSEL2_SHIFT)
	as Dma2P;

  Control	   = ControlP;
  Channel0	   = Dma0P;
  Channel1	   = Dma1P;
  Channel2	   = Dma2P;
  Dma0P.Interrupt -> ControlP.DmaInterrupt[0];
  Dma1P.Interrupt -> ControlP.DmaInterrupt[1];
  Dma2P.Interrupt -> ControlP.DmaInterrupt[2];
}
