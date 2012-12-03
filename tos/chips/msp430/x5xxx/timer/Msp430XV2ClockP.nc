/*
 * Copyright (c) 2011 Eric B. Decker
 * Copyright (c) 2009-2010 People Power Co.
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
 * Clock configuration for an MSP430XV2 board.
 *
 * @note If changing the rate for SMCLK, also update the UART configuration in
 * hardware/usci/PlatformSerialP.nc
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#include "msp430hardware.h"
#include "Msp430XV2Dco.h"

module Msp430XV2ClockP @safe() {
  provides {
    interface Init;
  }
  uses {
    interface Msp430XV2ClockControl;
  }
} implementation {

/*
 * Determine a default value for the DCO configuration, unless we
 * already have one.
 */
#ifndef MSP430XV2_DCO_CONFIG
/*
 * If somebody hasn't told us the preferred target DCO, look for it in
 * the legacy location
 */
#ifndef TARGET_DCO_HZ
#include "Msp430DcoSpec.h"
#endif /* TARGET_DCO_HZ */

/* Pick something based on target DCO */
#if 4194304 == TARGET_DCO_HZ
#define MSP430XV2_DCO_CONFIG MSP430XV2_DCO_8MHz_RSEL3
#else /* TARGET_DCO_HZ value */
#define MSP430XV2_DCO_CONFIG MSP430XV2_DCO_8MHz_RSEL3
#endif /* TARGET_DCO_HZ value */
#endif /* MSP430XV2_DCO_CONFIG */

  command error_t Init.init() {
    atomic {
      call Msp430XV2ClockControl.configureUnifiedClockSystem(MSP430XV2_DCO_CONFIG);
      call Msp430XV2ClockControl.configureTimers();
      call Msp430XV2ClockControl.start32khzTimer();
      call Msp430XV2ClockControl.startMicroTimer();
    }
    return SUCCESS;
  }
}
