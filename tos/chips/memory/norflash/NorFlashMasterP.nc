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
 *
 *
 * @author David Moss
 */

#include "flashcommands.h"
#include "platformflash.h"

module NorFlashMasterP {
  provides {
    interface Memory;
    interface NorFlashCommands;
  }
  uses {
    interface GeneralIO as Csn;
    interface SpiByte;
    interface CrcX<uint16_t>;
    interface BusyWait<TMicro, uint16_t>;
  }
}

implementation {
  
  /***************** Prototypes ****************/
  
  /***************** Memory Commands ****************/
  command void Memory.read(uint32_t addr, void *buf, uint32_t len) {
    int i;
    uint8_t *data = buf;

    call NorFlashCommands.newCommand(FLASH_READ, addr, FALSE);

    for(i = 0; i < len; i++) {
      *data = call SpiByte.write(0x0);
      data++;
    }
    call Csn.set();
    call NorFlashCommands.sleep();
  }

  command void Memory.write(uint32_t addr, void *buf, uint32_t len) {
    uint8_t *data = buf;
    uint32_t currentAddress = addr;

    while(addr < currentAddress + len) {
      call NorFlashCommands.newCommand(FLASH_PROGRAM, addr, TRUE);

      /*
       * After call NorFlashCommands.newCommand(), Csn is low and ready to go.
       *
       * Write a byte and increment the write address.
       * If the write address is on a page boundary, then the following is true:
       *
       *     addr % MEMORY_PAGE_SIZE == 0
       *
       * This means we should timeout on writing, raise Csn, and wait for the
       * page to finish up. Same thing goes for running out of total bytes
       * to write.
       *
       * After that we loop back and see how we're doing with
       * our total progress.  If we need to do more, we do more... or the
       * loop exits.
       */
      do {
        call SpiByte.write(*data);
        data++;
        addr++;
      } while(((addr % MEMORY_PAGE_SIZE) > 0)
          && (addr < (currentAddress + len)));

      // Wait for the current page to finish writing by reading the status
      // byte and waiting for the ^RDY bit to go low
      call NorFlashCommands.wait();
    }
    call Csn.set();
    call NorFlashCommands.sleep();
  }

  command void Memory.eraseBlock(uint16_t eraseUnitIndex) {
    uint32_t addr = eraseUnitIndex << MEMORY_ERASEUNIT_SIZE_LOG2;

    call NorFlashCommands.newCommand(FLASH_BLOCKERASE, addr, TRUE);
    call NorFlashCommands.wait();
    call NorFlashCommands.sleep();
  }

  command void Memory.eraseChip() {
    call NorFlashCommands.newCommand(FLASH_CHIPERASE, FLASH_INVALID_ADDRESS, TRUE);
    call NorFlashCommands.wait();
    call NorFlashCommands.sleep();
  }

  command void Memory.flush() {
  }

  command uint16_t Memory.crc(uint32_t addr, uint32_t len, uint16_t baseCrc) {
    uint32_t currentAddress = addr;
    uint8_t latestRead;

    call NorFlashCommands.newCommand(FLASH_READ, addr, FALSE);
    for( ; addr < currentAddress + len; addr++) {
      latestRead = call SpiByte.write(0x0);
      baseCrc = call CrcX.seededCrc(baseCrc, &latestRead, 1);
    }
    call Csn.set();
    call NorFlashCommands.sleep();
    return baseCrc;
  }

  /***************** NorFlashCommands ****************/
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

  command void NorFlashCommands.newCommand(uint8_t cmd, uint32_t addr, bool write) {

#if FLASH_IMPLEMENTS_POWERDOWN
    uint8_t i;

    call Csn.clr();

    /*
     * The release from deep power-down command takes a FLASH_RES command byte,
     * 3 dummy address bytes, and 1 more dummy byte to read out the ID of the
     * flash chip. We loop the command 5 times to do this.
     *
     * If the flash chip is already awake or doing something else, this
     * command has no effect.
     */
    for(i = 0; i < 5; i++) {
      call SpiByte.write(FLASH_RES);
    }

    call Csn.set();

    // Wait until the flash chip is awake
    call BusyWait.wait(FLASH_TRES_MICROSECONDS);
#endif

    call NorFlashCommands.wait();
    call Csn.clr();
    if(write) {
      call SpiByte.write(FLASH_WREN);
      call Csn.set();
      call Csn.clr();
    }

    call SpiByte.write(cmd);
    if(addr != FLASH_INVALID_ADDRESS) {
      call SpiByte.write(addr >> 16);
      call SpiByte.write(addr >> 8);
      call SpiByte.write(addr);
    }
  }

  /**
   * Wait for the flash chip to be ready
   */
  command void NorFlashCommands.wait() {
    bool notReady;
    uint16_t ctr = 0;

    do {
      call Csn.set();
      call Csn.clr();
      call SpiByte.write(FLASH_RDSR);
      notReady = call SpiByte.write(0x0) & FLASH_STATUS_WRITING;
    } while(notReady && --ctr);
    call Csn.set();
  }

  /** 
   * Put the flash chip to sleep. Some flash chips do this automatically
   * when you release CSn, some don't.  In the generic implementation,
   * we'll send the command either way.
   */
  command void NorFlashCommands.sleep() {
#if FLASH_IMPLEMENTS_POWERDOWN
    call NorFlashCommands.newCommand(FLASH_POWERDOWN, FLASH_INVALID_ADDRESS, FALSE);
#endif
  }
}
