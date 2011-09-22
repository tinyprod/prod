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
 * Implementation of the HAL level component for the MSP430 DMA module.
 * This configuration provides the available DMA channels through the
 * MSP430DMA parameterized interface.
 *
 * (is the following still supported?)  If more channels are requested
 * than available through unique("DMA"), there will be no mapping for
 * that channel and compilation will fail.
 *
 * @author Ben Greenstein <ben@cs.ucla.edu>
 * @author Jonathan Hui <jhui@archrock.com>
 * @author Joe Polastre <info@moteiv.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#if !defined(__MSP430_HAS_DMA_3__) && !defined(__MSP430_HAS_DMAX_3__)
#error "Msp430DmaC: processor not supported, 3 DMA channels"
#endif

configuration Msp430DmaC {
  provides {
    interface Msp430DmaControl as Control;
    interface Msp430DmaChannel as Channel0;
    interface Msp430DmaChannel as Channel1;
    interface Msp430DmaChannel as Channel2;
  }
}
implementation {

  components HplMsp430DmaC as HplDmaC;

  components new Msp430DmaChannelP() as Channel0P;
  Channel0 = Channel0P;
  Channel0P.HplChannel -> HplDmaC.Channel0;

  components new Msp430DmaChannelP() as Channel1P;
  Channel1 = Channel1P;
  Channel1P.HplChannel -> HplDmaC.Channel1;

  components new Msp430DmaChannelP() as Channel2P;
  Channel2 = Channel2P;
  Channel2P.HplChannel -> HplDmaC.Channel2;

  components Msp430DmaControlP as ControlP;
  Control = ControlP;
  ControlP.HplControl  -> HplDmaC;
  ControlP.HplChannel0 -> HplDmaC.Channel0;
  ControlP.HplChannel1 -> HplDmaC.Channel1;
  ControlP.HplChannel2 -> HplDmaC.Channel2;
}
