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

/**
 * Hardware presentation for an entire RF1A radio module.
 *
 * This configuration integrates low-level hardware interactions with
 * TEP108-style resource management, permitting the radio to be shared
 * among components that use distinct radio configurations.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

generic configuration HplMsp430Rf1aC (
  /** Offset of RF1AxIFCTL0_ register for x=module_instance */
  unsigned int RF1AxIFCTL0_,
  /** Name of resource used to arbitrate modes of this USCI instance */
  char CLIENT_RESOURCE[]
) @safe() {
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
    interface Rf1aConfigure[uint8_t client];
    interface Rf1aTransmitFragment[uint8_t client];
  }
} implementation {
  enum {
    /** Identifier for this RF1A module, unique across chip */
    RF1A_ID = unique(UQ_MSP430_RF1A)
  };

  components new HplMsp430Rf1aIfP(RF1A_ID, RF1AxIFCTL0_) as HplRf1aIfP;
  HplMsp430Rf1aIf = HplRf1aIfP;

  components new SimpleFcfsArbiterC(CLIENT_RESOURCE) as ArbiterC;
  Resource = ArbiterC;
  ResourceRequested = ArbiterC;
  ArbiterInfo = ArbiterC;

  components new HplMsp430Rf1aP() as HplRf1aP;
  HplRf1aP.Rf1aIf -> HplRf1aIfP;
  ArbiterC.ResourceConfigure -> HplRf1aP;
  HplRf1aP.ArbiterInfo -> ArbiterC;
  Rf1aConfigure = HplRf1aP;
  Rf1aPhysical = HplRf1aP;
  Rf1aPhysicalMetadata = HplRf1aP;
  Rf1aTransmitFragment = HplRf1aP;
  Rf1aStatus = HplRf1aP;

  components HplMsp430Rf1aInterruptP;
  HplRf1aP.Rf1aInterrupts -> HplMsp430Rf1aInterruptP;
  HplMsp430Rf1aInterruptP.ArbiterInfo -> ArbiterC;

  components LedsC;
  HplRf1aP.Leds -> LedsC;
  HplMsp430Rf1aInterruptP.Leds -> LedsC;
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
