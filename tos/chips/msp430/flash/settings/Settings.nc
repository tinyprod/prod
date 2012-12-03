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
 * Manage storing and retrieving configuration settings 
 * for various components, mainly to non-volatile internal microcontroller 
 * memory.
 * 
 * On install, the internal flash should be erased automatically on
 * both the avr and msp430 platforms, so you shouldn't have to worry
 * about loading incorrect config data left over from a different
 * version of the application.
 *
 * On boot, each unique parameterized Settings interface will
 * be called with an event to requestLogin().  The component
 * using the Settings interface must call the command login(..)
 * at that point to register its global buffers that store configuration data.
 * After all components have logged in, the loaded() event will be automatically
 * signaled for each client, with their loaded data.
 *
 * Each request will be queued up and handled, so several components can call
 * store() and load() simultaneously.  The only rule is that the a single
 * component cannot store() and load() at the same time.
 *
 *
 * Storing data will first calcute and store the CRC of the data to flash,
 * then store the actual data to flash.  Each client will take up the
 * size they register with plus 2 bytes extra for the CRC.
 *
 * Loading data will first load the CRC from flash, then load the
 * data from flash into the registered client's pointer.  If
 * the CRC's don't match, then the loaded() event will signal with
 * valid == FALSE and error == SUCCESS.  You can then fill
 * in the registered buffer with default data and call store().
 *
 * @author David Moss
 */

interface Settings {

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
  command error_t login(void *data, uint8_t size);

  /**
   * Store the registered configuration data 
   * into non-volatile memory.  This assumes that the pointer
   * to the global data has not changed.
   * @return 
   *    SUCCESS if the configuration data will be stored
   *    FAIL if it will not be stored because you didn't log in
   */
  command error_t store();

  /**
   * Load the registered configuration data
   * from non-volatile memory into the registered buffer location.
   * @return 
   *     SUCCESS if the data loaded with CRC OK
   *     FAIL if you didn't previously log in when requested
   *     EINVAL if the data didn't load because CRC wasn't OK
   */
  command error_t load();
  
  /**
   * The configuration manager requests registration information.
   *
   * The command register(..) must be called within the event
   * for each component that uses the Configuration interface.
   * If register() is not called from within this event, then
   * that parameterized interface will not be allowed to store
   * or retrieve its configuration data on non-volatile memory.
   */
  event void requestLogin();
}
