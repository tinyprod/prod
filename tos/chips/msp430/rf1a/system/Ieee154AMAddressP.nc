/*
 * Copyright (c) 2010 People Power Co.
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

/** Implement the ActiveMessageAddress interface on top of an IEEE
 * 802.15.4 address configuration.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module Ieee154AMAddressP {
  provides {
    interface ActiveMessageAddress;
  }
  uses {
    interface Ieee154Address;
  }
} implementation {

#include "AM.h"

  async command void ActiveMessageAddress.setAddress (am_group_t group, am_addr_t addr) {
    call Ieee154Address.setAddress((ieee154_panid_t)group,
                                   (ieee154_saddr_t) addr);
  }

  async command am_addr_t ActiveMessageAddress.amAddress () {
    return (am_addr_t) call Ieee154Address.shortAddress();
  }

  async command am_group_t ActiveMessageAddress.amGroup () {
    return (am_group_t) call Ieee154Address.panId();
  }

  async event void Ieee154Address.changed () { signal ActiveMessageAddress.changed(); }

  default async event void ActiveMessageAddress.changed () { }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
