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

#include "Msp430Flash.h"

module SettingsP {
  provides {
    interface Init;
    interface Settings[uint8_t id];
  }
  uses {
    interface Msp430FlashModify;
    interface CrcX<uint16_t>;
  }
}

implementation {

  enum {
    NUM_CLIENTS = uniqueCount(UQ_MSP430_SETTINGS) + SETTINGS_CLIENT_BASE
  };

  typedef uint8_t settings_crc_t;

  /**
   * Information about all the parameterized clients
   * using the Settings interface
   */
  struct clients {
    /** Pointer to the client's configuration buffer */
    void *buffer;

    /** Size of the client's configuration buffer */
    uint8_t size;

  } clients[NUM_CLIENTS];


  /***************** Prototypes ****************/
  uint16_t getFlashAddress(uint8_t clientId);

  /***************** Init Commands ****************/
  command error_t Init.init() {
    int i;

    memset(&clients, 0x0, sizeof(clients));

    for(i = 0; i < NUM_CLIENTS; i++) {
      signal Settings.requestLogin[i]();
    }
    return SUCCESS;
  }

  /***************** Settings Commands ****************/
  /**
   * This command must be called during the requestLogin()
   * event.
   *
   * If registering this client causes the amount of config data to exceed
   * the size of the flash, this command will return ESIZE and
   * the client will not be allowed to use the Settings storage.
   *
   * Once the client logs in successfully, data is automatically 
   * loaded from non-volatile memory into RAM. If the CRC is good,
   * this login() command returns SUCCESS. If the CRC is bad,
   * it returns EINVAL.
   * 
   * @param data Pointer to the buffer that contains the local
   *     component's configuration data in global memory.
   * @param size Size of the buffer that contains local config data.
   * @return 
   *     SUCCESS if the client got registered and the data loaded with CRC OK
   *     EINVAL if the client got registered and the data didn't load (i.e.
   *         the very first time you power up the device perhaps).
   *     ESIZE if there is not enough memory
   *     FAIL if the client cannot login at this time because you
   *         weren't paying attention to the instructions. :)
   */
  command error_t Settings.login[uint8_t id](void *data, uint8_t size) {
    if(clients[id].size == 0) {

      clients[id].buffer = data;
      clients[id].size = size;

      if(getFlashAddress(id) + size > FLASH_SEGMENT_SIZE) {
        clients[id].size = 0;
        return ESIZE;
      } else {
        // Immediately request to load data from flash
        return call Settings.load[id]();
      }
    }
    return FAIL;
  }

  /**
   * Store the registered configuration data 
   * into non-volatile memory.  This assumes that the pointer
   * to the global data has not changed.
   * @return 
   *    SUCCESS if the configuration data will be stored
   *    FAIL if it will not be stored because you didn't log in
   */
  command error_t Settings.store[uint8_t id]() {
    uint16_t address;
    settings_crc_t crc;

    if(!(clients[id].size)) {
      return FAIL;
    }

    address = getFlashAddress(id);
    crc = (settings_crc_t) call CrcX.crc(clients[id].buffer, clients[id].size);

    call Msp430FlashModify.modify(address, &crc, sizeof(crc));
    call Msp430FlashModify.modify(address + sizeof(crc),
        clients[id].buffer, 
            clients[id].size);
    return SUCCESS;
  }

  /**
   * Load the registered configuration data
   * from non-volatile memory into the registered buffer location.
   * @return 
   *     SUCCESS if the data loaded with CRC OK
   *     FAIL if you didn't previously log in when requested
   *     EINVAL if the data didn't load because CRC wasn't OK
   */
  command error_t Settings.load[uint8_t id]() {
    uint16_t address;
    settings_crc_t crc;

    if(!(clients[id].size)) {
      return FAIL;
    }

    address = getFlashAddress(id);

    call Msp430FlashModify.read(address, &crc, sizeof(crc));
    call Msp430FlashModify.read(address + sizeof(crc), clients[id].buffer, clients[id].size);

    if(crc == (settings_crc_t) call CrcX.crc(clients[id].buffer, clients[id].size)) {
      // Good read
      return SUCCESS;
    } else {
      // Corruption
      return EINVAL;
    }
  }

  /***************** Functions ****************/
  /**
   * @return the address on flash for a particular client's data
   */
  uint16_t getFlashAddress(uint8_t clientId) {
    uint16_t addr = 0;
    int i;

    for(i = 0; i < NUM_CLIENTS; i++) {
      if(i == clientId) {
        break;
      }

      if(clients[i].size > 0) {
        // Add 1 because of the 8-bit crc length
        addr += clients[i].size + sizeof(settings_crc_t);
      }
    }
    return addr;
  }
  
  /***************** Defaults ****************/
  default event void Settings.requestLogin[uint8_t id]() { }
}
