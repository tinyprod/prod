/*
 * Copyright (c) 2011 Eric B. Decker
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
 * @author Eric B. Decker <cire831@gmail.com>
 *
 * See Msp430Dma.h for major changes.
 */

#include <Msp430Dma.h>

interface HplMsp430DmaChannel {

  /**
   * Set/Get the DMA Channel Control word.
   *
   * Use cpu defines to control a dma channel.  ie.
   *
   * call DMA.setChannelControl( DMA_DT_SINGLE | DMA_DT_RPT | DMASBDB
   *             | DMA_SRC_INC | DMA_DST_INC | DMAEN);
   *
   * You should leave the following bits alone:
   *
   *     DMAREQ, DMAABORT, DMAIE, and DMAIFG
   *
   * There are seperate routines for manipulating or testing
   * those bits.
   */
  async command void		setChannelControl(uint16_t ctl);
  async command uint16_t	getChannelControl();

  async command void		setTrigger(dma_trigger_t trigger);
  async command dma_trigger_t	getTrigger();

  async command void		enableDMA();
  async command void		disableDMA();

  async command void		enableInterrupt();
  async command void		disableInterrupt();

  async command bool		interruptPending();
  async command void		clearInterrupt();

  async command bool		aborted();

  async command void		triggerDMA();

  async command void		setSrc(uint16_t saddr);
  async command uint16_t	getSrc();

  async command void		setDst(uint16_t daddr);
  async command uint16_t	getDst();

  async command void		setSize(uint16_t sz);
  async command uint16_t	getSize();

  /**
   * Channel Reset
   *
   * Turn a dma channel off.  Force reset.
   * will set Channel Control to 0
   * will set Channel trigger to 0
   */
  async command void		reset();

  async event void		transferDone();
}
