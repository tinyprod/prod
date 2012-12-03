/*
 * Copyright (c) 2010-2011 Eric B. Decker
 * Copyright (c) 2009 DEXMA SENSORS SL
 * Copyright (c) 2005-2006 Arch Rock Corporation
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

/*
 * SPI1: SPI/USCI_B1.  Defaults to no DMA.
 *
 * On the x2xxx processors, USCI_B1 does not have any DMA triggers available
 * on the DMA engine so SPI1 does not support DMA.  Note....  This only
 * applies for the x2xxx processors.  x5xxx processors have more triggers so
 * can support DMA.   But the control files for this are in a completely different
 * directory (x5xxx/usci).
 *
 * This argues for this being a platform thing.  The platform indicates
 * what cpu is being used so also denotes what ports are available.
 *
 * Another way to handle this is with cpu functional ifdefs.  Ugly but
 * would work.  I think we really want the platform to provide SPI ports
 * which then determine what wires to what physical port.
 *
 * See msp430usci.h for port mappings.
 *
 * @author Jonathan Hui <jhui@archedrock.com>
 * @author Mark Hays
 * @author Xavier Orduna <xorduna@dexmatech.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#include "msp430usci.h"

generic configuration Msp430SpiB1C() {
  provides {
    interface Resource;
    interface ResourceRequested;
    interface SpiByte;
    interface SpiPacket;
  }
  uses interface Msp430SpiConfigure;
}

implementation {

  enum {
    CLIENT_ID = unique(MSP430_SPIB1_BUS),
  };

#ifdef ENABLE_SPIB1_DMA
#error "DMA is not available for SPI (usci B1)"
#endif

  components Msp430SpiB1NoDmaP as SpiP;
  Resource = SpiP.Resource[CLIENT_ID];
  SpiByte = SpiP.SpiByte;
  SpiPacket = SpiP.SpiPacket[CLIENT_ID];
  Msp430SpiConfigure = SpiP.Msp430SpiConfigure[CLIENT_ID];

  components new Msp430UsciArbB1C() as UsciC;
  ResourceRequested = UsciC;
  SpiP.ResourceConfigure[CLIENT_ID] <- UsciC.ResourceConfigure;
  SpiP.UsciResource[CLIENT_ID] -> UsciC.Resource;
  SpiP.UsciInterrupts -> UsciC.HplMsp430UsciInterrupts;
}
