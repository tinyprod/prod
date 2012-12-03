/*
 * Copyright (c) 2010 People Power Co.
 * All rights reserved.
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
 * A component that supports transmitting and receiving bare packets
 * using the RF1A infrastructure.
 *
 * @param BUFFER_SIZE The number of octets reserved for each of the
 * transmission and reception buffers.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

generic configuration BareRf1aC (unsigned int BUFFER_SIZE) {
  provides {
    interface BareTxRx;
    interface BareMetadata;
    interface SplitControl;
  }
} implementation {
  components new BareRf1aP(BUFFER_SIZE);

  components new Rf1aPhysicalC();
  BareRf1aP.Resource -> Rf1aPhysicalC;
  BareRf1aP.Rf1aPhysical -> Rf1aPhysicalC;
  BareRf1aP.Rf1aPhysicalMetadata -> Rf1aPhysicalC;

  BareTxRx = BareRf1aP;
  BareMetadata = BareRf1aP;
  SplitControl = BareRf1aP;
}
