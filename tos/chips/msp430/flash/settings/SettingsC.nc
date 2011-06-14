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
 * During software initialization, each unique parameterized Settings
 * interface will be called with an event to requestLogin().  The
 * component using the Settings interface must call command
 * Settings.login() at that point to register the address and size of
 * the structure that holds its configuration data.  After all
 * components have logged in, the Settings.loaded() event will be
 * automatically signaled for each client, with their loaded data.
 *
 * Each request will be queued up and handled, so several components can call
 * store() and load() simultaneously.  The only rule is that the a single
 * component cannot store() and load() at the same time.
 *
 * Storing data will first calcute and store the CRC of the data to
 * flash, then store the actual data to flash.  Each client will take
 * up the size they register with plus the size of the CRC.
 *
 * Loading data will first load the CRC from flash, then load the
 * data from flash into the registered client's pointer.  If
 * the CRC's don't match, then the loaded() event will signal with
 * valid == FALSE and error == SUCCESS.  You can then fill
 * in the registered buffer with default data and call store().
 *
 * @author David Moss
 */

#include "Settings.h"

generic configuration SettingsC() {
  provides interface Settings;
}
implementation {
  components SettingsImplC;
  Settings = SettingsImplC.Settings[unique(UQ_MSP430_SETTINGS) + SETTINGS_CLIENT_BASE];
}
