/* 
 * Copyright (c) 2009-2010 People Power Co.
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

#ifndef FLASHCOMMANDS_H
#define FLASHCOMMANDS_H

/**
 * Flash SPI bus commands
 * These were selected as the union between AT25 and M25 flash chip commands
 */

enum flash_commands_e {
  FLASH_WREN = 0x06,          // Set write enable latch
  FLASH_WRDI = 0x04,          // Reset write enable latch
  FLASH_RDSR = 0x05,          // Read status register
  FLASH_WRSR = 0x01,          // Write status register
  FLASH_READ = 0x03,          // Read data from memory array
  FLASH_FASTREAD = 0x0B,      // Read data from memory array (with dummy cycles)
  FLASH_PROGRAM = 0x02,       // Program data into memory array

  FLASH_BLOCKERASE = 0xD8,    // Erase one block in memory array
  FLASH_CHIPERASE = 0xC7,     // Erase all memory array
  FLASH_RDID = 0x9F,          // Read manufacturer and product ID (on most chips)

  FLASH_POWERDOWN = 0xB9,     // Deep power down on some flash chips
  FLASH_RES = 0xAB,           // Release from deep power down and read ID
};

/**
 * Status bit definitions, where they're the same across multiple flash chips
 */
enum flash_status_e {
  FLASH_STATUS_WRITING = 0x1,
};

/**
 * Special flash address definitions
 */

enum flash_address_e {
  FLASH_INVALID_ADDRESS = 0xFFFFFFFF,
};

#endif
