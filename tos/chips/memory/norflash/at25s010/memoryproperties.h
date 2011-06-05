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
 */

/**
 * @author David Moss
 */

#ifndef FLASHPROPERTIES_H
#define FLASHPROPERTIES_H

/**
 * Set this to a 1 if this flash chip provides a deep power-down command
 */
#ifndef FLASH_IMPLEMENTS_POWERDOWN
#define FLASH_IMPLEMENTS_POWERDOWN 0
#endif

/**
 * Flash properties
 * We match these to the default commands in flashcommands.h
 * Specifically, the erase command is 0xD8 which is a block erase, which is 
 * 32 kB.  The AT25S010 also has a sector erase, but that can be implemented
 * on a chip-specific interface.
 */

enum {
  MEMORY_NUM_ERASEUNITS = 4,
  MEMORY_ERASEUNIT_SIZE_LOG2 = 15,   // In other words, 1000000000000000'b = 0x8000 = 32kB
  MEMORY_ERASEUNIT_SIZE = 1L << MEMORY_ERASEUNIT_SIZE_LOG2,

  MEMORY_NUM_PAGES = 128,
  MEMORY_PAGE_SIZE_LOG2 = 8,  // In other words, 100000000'b = 0x100 = 256 B
  MEMORY_PAGE_SIZE = 1 << MEMORY_PAGE_SIZE_LOG2,

  MEMORY_INVALID_ADDRESS = 0xFFFFFFFF,
};

#endif
