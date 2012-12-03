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
 * This interface allows external components to take advantage of existing
 * command instructions to send raw commands to the flash chip
 * over the single-phase SpiByte interface.
 *
 * You could use this interface to implement chip-specific commands,
 * or access it to put the flash chip manually into deep sleep mode.
 * 
 * @author David Moss
 */

interface NorFlashCommands {

  /**
   * Start a new command to the flash chip. Pay close attention to the 
   * behavior of this command! It will always clear the chip select line CSn
   * in order to send the command to the chip, and will not set the CSn line
   * high again because you may want to continue sending the flash chip
   * bytes.  You must manually set the CSn line high when you're done
   * with your new command.
   *
   * @param cmd The command byte to send
   * @param addr The address to send as part of the command
   *     If FLASH_INVALID_ADDRESS is given, the address isn't sent.
   * @param write TRUE to properly enable write access to the chip
   */

  command void newCommand(uint8_t cmd, uint32_t addr, bool write);

  /**
   * Blocks until the chip is ready and done writing
   */
  command void wait();

  /** 
   * Put the flash chip to sleep. Some flash chips do this automatically
   * when you release CSn, some don't.  In the generic implementation,
   * we'll send the command either way.
   */
  command void sleep();
}
