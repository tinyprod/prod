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
 * This is the easy-to-find façade for the specific NOR-flash memory chip 
 * implementation.  A platform should include the memory/norflash directory at 
 * compile time, as well as a specific NOR-flash chip sub-directory.
 *
 * The ExternalMemoryC configuration is the generic entry point that 
 * applications should typically use. The generic name "ExternalMemoryC"
 * was chosen because the type of external memory on other platforms may
 * not be a NOR-flash type. Other types of memory may include EEPROM and
 * NAND-flash, which can provide a similar generic Memory interface but
 * have different properties / master implementations behind them to make
 * them behave the same.
 *
 * To access chip-specific commands and features, wire directly to extra 
 * interfaces that can be provided by the chip-specific FlashImplementationC 
 * configuration.  Remember, extra redirected plumbing costs nothing in terms of 
 * application footprint.
 *
 * Specific flash chips do not have to add any extra chip-specific interfaces 
 * and may simply forward the mandatory Resource and DirectStorage interfaces
 * to the NorFlashMasterC component.  Each flash chip should provide a
 * flashproperties.h file which describes the erase units and write units
 * of the flash.
 *
 * @author David Moss
 */

configuration ExternalMemoryC {
  provides {
    interface Resource;
    interface Memory;
  }
}
implementation {
  components MemoryImplementationC;
  Resource = MemoryImplementationC;
  Memory = MemoryImplementationC;
}
