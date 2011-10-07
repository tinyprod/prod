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
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

#ifndef _MSP430XV2DCO_H
#define _MSP430XV2DCO_H

/**
 * Define material relevant to configuring the DCO on an MSP430
 * Unified Clock System module.
 *
 * DCO configuration is normally performed in Msp430XV2ClockControlP.
 * DCO rates below are in binary megahertz (viz., 4MiHz == 2^24Hz).  In
 * the default implementation ACLK is always at 2^15 Hz (32KiHz), MCLK
 * is always half the DCO rate, and SMCLK is scaled to be 1MiHz
 * (2^20Hz).  The frequency range selection value is taken from the
 * "DCO Frequency" table in the chip-specific electrical
 * characteristics datasheet.  Where one DCO frequency is available as
 * multiple RSEL values, it is because that frequency can be obtained
 * with two different configurations, which may have different
 * stability characteristics.  It is the developer's responsibility to
 * select the correct DCO/RSEL pairing for the target chip.
 *
 * Warning: TinyOS likes timers/clocks to be powers of 2.   This probably
 * was to make syncing the DCO to the 32KiHz time base easier.  But this
 * presents problems in juxtaposition with TI's chips.  The x5 chips can
 * have a variable Vcore which also determines what the maximum frequency
 * supported is.  All of the specs are given in terms of powers of ten.
 *
 * Relaxing the binary time constraint makes life easier for the h/w and
 * makes it easier to run the cpu at the full speed for a given Vcore.
 * This however makes TinyOS time a power of ten rather than binary.  This
 * probably isn't an issue as long as it is documented.
 */

/** Constants used to configure specific DCO rates on MSP430 chips. */
typedef enum Msp430XV2DcoConfig_e {
  MSP430XV2_DCO_2MHz_RSEL2,
  MSP430XV2_DCO_4MHz_RSEL3,
  MSP430XV2_DCO_8MHz_RSEL3,
  MSP430XV2_DCO_8MHz_RSEL4,
  MSP430XV2_DCO_16MHz_RSEL4,
  MSP430XV2_DCO_16MHz_RSEL5,
  MSP430XV2_DCO_32MHz_RSEL5,
  MSP430XV2_DCO_32MHz_RSEL6,
  MSP430XV2_DCO_64MHz_RSEL6,
  MSP430XV2_DCO_64MHz_RSEL7,
} Msp430XV2DcoConfig_e;

#endif // _MSP430XV2DCO_H
