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

#include "Rf1a.h"

/** Provide a unique client of a specific RF1A module.
 *
 * @note This module currently assumes there is but one RF1A module
 * available.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

generic configuration Rf1aPhysicalC () {
  provides {
    interface HplMsp430Rf1aIf;
    interface Resource;
    interface Rf1aPhysical;
    interface Rf1aPhysicalMetadata;
    interface Rf1aStatus;
  }
  uses {
    interface Rf1aTransmitFragment;
    interface Rf1aConfigure;
  }
} implementation {
  enum {
    /** Unique parameter used for this client */
    CLIENT = unique(UQ_RF1A_CLIENT),
  };

  components Rf1aC;
  HplMsp430Rf1aIf = Rf1aC;
  Resource = Rf1aC.Resource[CLIENT];
  Rf1aPhysical = Rf1aC.Rf1aPhysical[CLIENT];
  Rf1aTransmitFragment = Rf1aC.Rf1aTransmitFragment[CLIENT];
  Rf1aConfigure = Rf1aC.Rf1aConfigure[CLIENT];
  Rf1aPhysicalMetadata = Rf1aC;
  Rf1aStatus = Rf1aC;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
