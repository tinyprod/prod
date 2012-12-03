/* 
 * Copyright (c) 2009-2010 People Power Company
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
 * Msp430 User Flash
 * @author Jonathan Hui <jhui@archrock.com>
 * @author David Moss
 */

#if !defined(__MSP430_HAS_FLASH__) && !defined(__MSP430_HAS_FLASH2__)
#error "Msp430FlashP: processor not supported, need FLASH or FLASH2"
#endif

#if defined(__MSP430_HAS_FLASH2__)
#warn "Msp430FlashP: FLASH driver, FLASH2 defined, may not function correctly"
#endif

#include "Msp430Flash.h"

module Msp430FlashP {
  provides {
    interface Msp430Flash;
    interface Init;
  }
  uses interface Wdt;
}
implementation {

  /** TRUE if the device booted without previous modifications to user flash */
  bool notFirstBoot;

  /***************** Init Commands ****************/
  command error_t Init.init() {
    // Establish the notFirstBoot variable
    call Msp430Flash.isFirstBoot();
    return SUCCESS;
  }

  /***************** Msp430Flash Commands ****************/
  command error_t Msp430Flash.erase(uint16_t addr) {
    uint8_t *eraseAddr;

    if (addr > FLASH_TOTAL_SIZE) {
      return FAIL;
    }

    eraseAddr = (uint8_t *) (addr + FLASH_OFFSET);

    call Wdt.pause();
    FCTL3 = FWKEY + LOCKA;         // Clear LOCK and LOCKA
    FCTL1 = FWKEY + ERASE;         // Enable segment erase
    *eraseAddr = 0;                // Dummy write, erase the selected segment
    while(FCTL3 & BUSY);           // Wait for erase to finish
    FCTL1 = FWKEY;                 // Disable writes / erases
    FCTL3 = FWKEY + LOCK + LOCKA;  // Set LOCK and LOCKA
    call Wdt.resume();
    return SUCCESS;
  }

  command error_t Msp430Flash.write(uint16_t addr, const void *buf, uint8_t len) {
    uint8_t *writeAddr;

    if (addr + len > FLASH_TOTAL_SIZE) {
      return FAIL;
    }

    writeAddr = (uint8_t *) (addr + FLASH_OFFSET);

    call Wdt.pause();
    FCTL3 = FWKEY + LOCKA;         // Clear LOCK and LOCKA
    FCTL1 = FWKEY + WRT;           // Enable write
    memcpy(writeAddr, buf, len);   // Write
    while(FCTL3 & BUSY);           // Wait for write to finish
    FCTL1 = FWKEY;                 // Disable writes / erases
    FCTL3 = FWKEY + LOCK + LOCKA;  // Set LOCK and LOCKA
    call Wdt.resume();
    return SUCCESS;
  }

  command error_t Msp430Flash.read(uint16_t addr, void *buf, uint8_t len) {
    uint16_t *address;

    if (addr + len > FLASH_TOTAL_SIZE) {
      return FAIL;
    }

    address = (uint16_t *) (addr + FLASH_OFFSET);
    memcpy(buf, address, len);
    return SUCCESS;
  }

  command bool Msp430Flash.isFirstBoot() {
    uint8_t *i;

    // Check segments b, c, d for written bytes
    for(i = (uint8_t *) FLASH_OFFSET; i < (uint8_t *) (FLASH_OFFSET + (FLASH_SEGMENT_SIZE * 3)); i++) {
      notFirstBoot |= (*i != FLASH_FILL_BYTE);
    }
    return !notFirstBoot;
  }
}
