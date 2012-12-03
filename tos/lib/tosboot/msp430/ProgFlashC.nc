/*
 * Copyright (c) 2011 Eric B. Decker
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
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
 * @author Jonathan Hui <jwhui@cs.berkeley.edu>
 * @author Eric B. Decker <cire831@gmail.com>
 *
 * This module supports writing to Flash on MSP430 processors.  Currently
 * only handles writing flash in the lower 48 whoops lower 64K.  The newer
 * processors have more flash.  Eventually we'll want to extend this.
 *
 * Currently, if someone tries to use another processor other than the old
 * ones we bitch.  That is just to flag that things are other than
 * they seem.
 *
 * We could check for __MSP430_HAS_MSP430X_CPU__ or __MSP430_HAS_MSP430XV2_CPU__
 * but it is better to more restrictive.  The idea is force people to look
 * at stuff written for previous processors when a new processor is brought over
 * (ie. ported to TinyOS).   Active involvement rather than things kind of work.
 */

#if !defined(__msp430x14x) && !defined(__msp430x16x)
#warn "ProgFlashC: limited to lower 64K (x149 and x1611)"
#endif

module ProgFlashC {
  provides {
    interface ProgFlash;
  }
}

implementation {

  enum {
    RESET_ADDR = 0xfffe,
  };

  command error_t ProgFlash.write(in_flash_addr_t addr, uint8_t* buf, uint16_t len) {

    volatile uint16_t *flashAddr = (uint16_t*)(uint16_t)addr;
    uint16_t *wordBuf = (uint16_t*)buf;
    uint16_t i = 0;

    // len is 16 bits so it can't be larger than 0xffff
    // make sure we can't wrap around
    if (addr < (0xffff - (len >> 1))) {
      FCTL2 = FWKEY + FSSEL1 + FN2;
      FCTL3 = FWKEY;
      FCTL1 = FWKEY + ERASE;
      *flashAddr = 0;
      FCTL1 = FWKEY + WRT;
      for (i = 0; i < (len >> 1); i++, flashAddr++) {
	if ((uint16_t)flashAddr != RESET_ADDR)
	  *flashAddr = wordBuf[i];
	else
	  *flashAddr = TOSBOOT_START;
      }
      FCTL1 = FWKEY;
      FCTL3 = FWKEY + LOCK;
      return SUCCESS;
    }
    return FAIL;
  }

}
