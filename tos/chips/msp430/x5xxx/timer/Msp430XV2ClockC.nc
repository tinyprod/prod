/*
 * Copyright (c) 2011, Eric B. Decker
 * Copyright (c) 2010, People Power Co.
 * Copyright (c) 2000-2003 The Regents of the University of California.
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
 * Configuration for the clocks and timers on an x5 family processor
 * (MSP430XV2).
 *
 * The actual setting of the h/w occurs in Msp430XV2ClockP.   T0A5 is
 * used to provide a 32KiHz timebase and T1A3 is used to provide
 * a 1MiHz timebase.
 *
 * If your board requires other configurations, implement
 * Msp430XV2ClockInit in your own component and connect to this
 * implementation's events to override each configuration step as
 * necessary.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

configuration Msp430XV2ClockC {
  provides {
    interface Init;
    interface Msp430XV2ClockControl;
    interface StdControl as InhibitUcs7WorkaroundControl;
  }
}
implementation {
  components Msp430XV2ClockP;
  Init = Msp430XV2ClockP;

  /*
   * Must reference Msp430TimerC, since the Msp430XV2ClockInit code
   * will enable interrupts that are only defined if that component is
   * linked in.
   */
  components Msp430TimerC;

  components Msp430XV2ClockControlP;
  Msp430XV2ClockControl = Msp430XV2ClockControlP;
  InhibitUcs7WorkaroundControl = Msp430XV2ClockControlP.InhibitUcs7WorkaroundControl;
  Msp430XV2ClockP.Msp430XV2ClockControl -> Msp430XV2ClockControlP;

  components McuSleepC;
  McuSleepC.McuPowerOverride -> Msp430XV2ClockControlP;

  /* Work around UCS7 */
  Msp430XV2ClockControlP.McuSleepEvents -> McuSleepC;
}
