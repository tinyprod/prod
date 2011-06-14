/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
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

#include "Msp430Flash.h"

/**
 * @author David Moss
 * @author Jonathan Hui
 */

module Msp430FlashModifyP {
  provides interface Msp430FlashModify;
  uses     interface Msp430Flash;
}
implementation {

  /***************** Prototypes ****************/
  uint8_t chooseSegment();

  /***************** Msp430FlashModify Commands ****************/
  command error_t Msp430FlashModify.read(uint16_t addr, void *buf, uint8_t len) {
    if (chooseSegment()) {
      addr += FLASH_SEGMENT_SIZE;
    }
    return call Msp430Flash.read(addr, buf, len);
  }

  command error_t Msp430FlashModify.modify(uint16_t addr, const void *buf, uint8_t len) {
    uint16_t newWriteAddr = 0x0;
    uint16_t offset = 0x0;
    uint8_t *oldBuffer_ptr = (uint8_t *) FLASH_OFFSET;
    uint8_t version;

    if (addr + len > FLASH_BOUND_HIGH) {
      return FAIL;
    }

    if (chooseSegment()) {
      oldBuffer_ptr += FLASH_SEGMENT_SIZE;
      version = *(uint8_t *) FLASH_VNUM_ADDR_1;
    } else {
      newWriteAddr += FLASH_SEGMENT_SIZE;
      version = *(uint8_t *) FLASH_VNUM_ADDR_0;
    }

    atomic {
      call Msp430Flash.erase(newWriteAddr);    

      call Msp430Flash.write(newWriteAddr, oldBuffer_ptr, addr);
      offset += addr;
      call Msp430Flash.write(newWriteAddr + offset, buf, len);
      offset += len;
      // Subtract 1 at the end to leave room for the version byte
      call Msp430Flash.write(newWriteAddr + offset, oldBuffer_ptr + offset, FLASH_SEGMENT_SIZE - offset - 1);

      version++;
      if (version == FLASH_FILL_BYTE) {
        version = 0;
      }

      call Msp430Flash.write(newWriteAddr + FLASH_SEGMENT_SIZE - 1, &version, 1);
    }
    return SUCCESS;
  }
  
  /***************** Functions ****************/
  uint8_t chooseSegment() {
    uint8_t vnum0 = *(uint8_t *) FLASH_VNUM_ADDR_0;
    uint8_t vnum1 = *(uint8_t *) FLASH_VNUM_ADDR_1;

    if ((vnum0 == FLASH_FILL_BYTE) || (vnum1 == 0 && vnum0 == 0xFE)) {
      return 1;
    } else if ((vnum1 == FLASH_FILL_BYTE) || (vnum0 == 0 && vnum1 == 0xFE)) {
      return 0;
    } else {
      return (vnum0 < vnum1);
    }
  }
}
