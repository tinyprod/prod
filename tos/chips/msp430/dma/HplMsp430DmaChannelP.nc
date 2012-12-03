/*
 * Copyright (c) 2011 Eric B. Decker
 * Copyright (c) 2005-2006 Arch Rock Corporation
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
 * @author Ben Greenstein <ben@cs.ucla.edu
 * @author Jonathan Hui <jhui@archrock.com>
 * @author Joe Polastre <info@moteiv.com>
 * @author Mark Hays
 * @author Eric B. Decker <cire831@gmail.com>
 */

#if !defined(__MSP430_HAS_DMA_3__) && !defined(__MSP430_HAS_DMAX_3__)
#error "HplMsp430DmaChannelP: processor not supported, need DMA_3 or DMAX_3"
#endif

/**
 * Define a DMA channel.
 *
 * DMAxCTL:	Channel control word.  ie.  DMA0CTL (control word for
 *		channel 0.  This word contains various selects including
 *		byte/word, transfer mode, increment, DMAEN, DMAIE, DMAIFG, etc.
 *
 *		It is intended that DMAxCTL is set using various defines from
 *		a processor specific include.  ie.
 *
 *		    call DMA.setChannelControl(DMA_DT_SINGLE | DMASWDW | DMAEN
 *				| DMASRC_INC | DMADST_INC);
 *
 * DMAxSA:	Channel Source Address.  16 bits.
 * DMAxDA:	Channel Dest Address.    16 bits.
 * DMAxSZ:	Channel Size.  16 bits.  1 - 65535 bytes or words.  0 disables.
 * TSEL_base:	byte pointer to TSEL (trigger select) control word.  If TSEL is
 *		4 bits, there are two TSELs per word.  5 bit TSELs show up one
 *		byte.
 * TSEL_mask:	0xf for 4 bit TSELs and 0x1f for 5 bit.
 * TSEL_shift:	Used to select either the left nibble or right nibble of the
 *		TSEL byte.
 *
 * Actual values for these puppies are set in Msp430Dma.h based on what
 * processor is being used.
 */

generic module
  HplMsp430DmaChannelP( uint16_t DMAxCTL_addr,
			uint16_t DMAxSA_addr,
			uint16_t DMAxDA_addr,
			uint16_t DMAxSZ_addr,
			uint16_t DMAxTSEL_base,
			uint16_t DMAxTSEL_mask,
			uint16_t DMAxTSEL_shift) @safe() {
  
  provides interface HplMsp430DmaChannel as DMA;
  uses interface HplMsp430DmaInterrupt as Interrupt;

}

implementation {

#define DMAxCTL (*(volatile TYPE_DMA0CTL *) DMAxCTL_addr)
#define DMAxSA  (*(volatile TYPE_DMA0SA  *) DMAxSA_addr)
#define DMAxDA  (*(volatile TYPE_DMA0DA  *) DMAxDA_addr)
#define DMAxSZ  (*(volatile TYPE_DMA0SZ  *) DMAxSZ_addr)
#define TSEL    (*(volatile TYPE_DMACTL0 *) DMAxTSEL_base)

  async command void DMA.setChannelControl(uint16_t ctl) {
    DMAxCTL = ctl;
  }

  async command uint16_t DMA.getChannelControl() {
    return DMAxCTL;
  }

  async void command DMA.setTrigger( dma_trigger_t trigger ) {
    atomic {
      TSEL = ((TSEL & ~(DMAxTSEL_mask << DMAxTSEL_shift)) |
	      ((trigger & DMAxTSEL_mask) << DMAxTSEL_shift));
    }
  }

  async command dma_trigger_t DMA.getTrigger() {
    atomic {
      return ((TSEL >> DMAxTSEL_shift) & DMAxTSEL_mask);
    }
  }

  async command void DMA.enableDMA() { 
    DMAxCTL |= DMAEN; 
  }

  async command void DMA.disableDMA() { 
    DMAxCTL &= ~DMAEN; 
  }

  async command void DMA.enableInterrupt() {
    DMAxCTL |= DMAIE;
  }

  async command void DMA.disableInterrupt() {
    DMAxCTL &= ~DMAIE;
  }

  async command bool DMA.interruptPending() {
    return (DMAxCTL & DMAIFG);
  }

  async command void DMA.clearInterrupt() {
    DMAxCTL &= ~DMAIFG;
  }

  async command bool DMA.aborted() {
    return (DMAxCTL & DMAABORT);
  }
  
  async command void DMA.triggerDMA() { 
    DMAxCTL |= DMAREQ; 
  }
  
  async command void DMA.setSrc(uint16_t saddr) {
    DMAxSA = saddr;
  }
  
  async command uint16_t DMA.getSrc() {
    return DMAxSA;
  }

  async command void DMA.setDst(uint16_t daddr) {
    DMAxDA = daddr;
  }
  
  async command uint16_t DMA.getDst() {
    return DMAxDA;
  }

  async command void DMA.setSize(uint16_t sz) {
    DMAxSZ = sz;
  }

  async command uint16_t DMA.getSize() {
    return DMAxSZ;
  }

  async command void DMA.reset() {
    call DMA.setChannelControl(0);	/* will kill DMAEN */
    call DMA.setTrigger(0);		/* will set to sw/dmareq */
  }

  /*
   * Interaction between NMI and DMA resulting in the ABORT
   * isn't clear.  Hasn't really been fleshed out and is mostly
   * ignored for now.   ABORT is stupid as is a maskable NMI.
   * It isn't at all clear what needs to happen if the DMA is
   * actually aborted because of a NMI.   Also no one seems to
   * actually look at the return status of a transferDone().
   * So remove it for now.
   */
  async event void Interrupt.fired() {
    DMAxCTL &= ~DMAIFG;
    signal DMA.transferDone();
  }
}
