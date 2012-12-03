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

/**
 * Master configuration for a single RF1A module.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */
configuration Rf1aC {

  provides {
    interface HplMsp430Rf1aIf;
    interface Resource[uint8_t client];
    interface ResourceRequested[uint8_t client];
    interface ArbiterInfo;
    interface Rf1aPhysical[uint8_t client];
    interface Rf1aPhysicalMetadata;
    interface Rf1aStatus;
  }
  uses {
    interface Rf1aTransmitFragment[uint8_t client];
    interface Rf1aConfigure[uint8_t client];
  }
} implementation {

  components new HplMsp430Rf1aC(RF1AIFCTL0_, UQ_RF1A_CLIENT) as HplRf1aC;
  HplMsp430Rf1aIf = HplRf1aC;
  Resource = HplRf1aC;
  ResourceRequested = HplRf1aC;
  ArbiterInfo = HplRf1aC;
  Rf1aPhysical = HplRf1aC;
  Rf1aPhysicalMetadata = HplRf1aC;
  Rf1aTransmitFragment = HplRf1aC;
  Rf1aConfigure = HplRf1aC;
  Rf1aStatus = HplRf1aC;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
