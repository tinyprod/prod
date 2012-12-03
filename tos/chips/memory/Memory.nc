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

/**
 * Rationale for a single-phase memory interface: 
 * Previous platforms had a radio chip and a flash chip tied to the same
 * SPI bus. This caused problems because both might want access simultaneously.
 * Since then, some platforms have opted to put the flash and radio on
 * separate SPI buses, or built the radio into the microcontroller as an SoC.
 * The radio / flash conflicts are not as prevalent as they used to be.
 *
 * Several issues arose from a split-phase interface:
 *
 * 1. Too much code to both generate and handle the events
 *
 * 2. Some events implemented as single-phase underneath could cause stack
 *    overflows when the same command was called from its event.
 *
 * A single-phase interface is easy to implement and can be very small. It
 * can avoid the stack overflow problems of a split-phase interface.
 *
 * Questions have also arisen in the past about whether eraseChip() and/or crc()
 * belong in a generic memory interface or a chip-specific one. After several
 * years of use, we've found the answer to be yes for both.  Even if a chip
 * doesn't provide an explicit eraseChip() command, the command can be 
 * emulated so the behavior stays as expected.  The crc(..) command can also 
 * be implemented at a lower level much more efficiently than at a higher
 * level because bytes can be read from memory and wrung through the crc
 * calculation without dedicating a buffer in RAM or spending cycles on 
 * overhead.
 *
 * To be compatible across most memory chips, the flush() command should be 
 * called when you're done writing.  If flush() is not implemented for your
 * memory chip, the command will be optimized out by the compiler. Cases where
 * flush() would be implemented include writing to a RAM buffer on the 
 * microcontroller to save up a page worth of memory before dumping to
 * flash, and a NOR-flash chip emulating the behavior of an EEPROM by providing 
 * built-in RAM buffers.
 */

interface Memory {

  /** 
   * Read bytes from memory
   * @param addr - the address to read from
   * @param *buf - the buffer to read into
   * @param len - the amount to read
   */
  command void read(uint32_t addr, void *buf, uint32_t len);

  /** 
   * Write bytes to memory
   * @param addr - the address to write to
   * @param *buf - the buffer to write from
   * @param len - the amount to write
   */
  command void write(uint32_t addr, void *buf, uint32_t len);

  /**
   * Erase a single erase unit
   * The first block index is 0, the second is 1, etc.
   * @param eraseUnitIndex the erase unit to erase, 0-indexed
   */
  command void eraseBlock(uint16_t eraseUnitIndex);

  /**
   * Erase the entire flash. Whether the chip was erased or not depends on if 
   * there were any protected blocks or sectors.
   */
  command void eraseChip();

  /**
   * Flush written data to memory. This only applies to some memory chips.
   */
  command void flush();

  /**
   * Obtain the CRC of some data sitting in memory
   * @param addr - the address to start the CRC computation
   * @param len - the amount of data to obtain the CRC for
   * @param baseCrc - the initial crc
   * @return the computed CRC-16
   */
  command uint16_t crc(uint32_t addr, uint32_t len, uint16_t baseCrc);
}
