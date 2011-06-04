/*
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
 * Msp430Timer32khzMapC presents as paramaterized interfaces all of the 32khz
 * hardware timers on the MSP430 that are available for compile time allocation
 * by "new Alarm32khz16C()", "new AlarmMilli32C()", and so on.
 *
 * Platforms based on the MSP430 are encouraged to copy in and override this
 * file, presenting only the hardware timers that are available for allocation
 * on that platform.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

/*
 * Currently, all MSP430XV2 architectures support T0A5, so we'll use
 * that for the 32KHz timer suite.  If you clone this to a platform
 * area, remember to also clone Msp430Counter32khzC if you change to a
 * different timer.
 */

configuration Msp430Timer32khzMapC {
  provides {
    interface Msp430Timer[ uint8_t id ];
    interface Msp430TimerControl[ uint8_t id ];
    interface Msp430Compare[ uint8_t id ];
  }
}
implementation {
  components Msp430TimerC;

  Msp430Timer[0] = Msp430TimerC.Timer0_A;
  Msp430TimerControl[0] = Msp430TimerC.Control0_A0;
  Msp430Compare[0] = Msp430TimerC.Compare0_A0;

  Msp430Timer[1] = Msp430TimerC.Timer0_A;
  Msp430TimerControl[1] = Msp430TimerC.Control0_A1;
  Msp430Compare[1] = Msp430TimerC.Compare0_A1;

  Msp430Timer[2] = Msp430TimerC.Timer0_A;
  Msp430TimerControl[2] = Msp430TimerC.Control0_A2;
  Msp430Compare[2] = Msp430TimerC.Compare0_A2;

  Msp430Timer[3] = Msp430TimerC.Timer0_A;
  Msp430TimerControl[3] = Msp430TimerC.Control0_A3;
  Msp430Compare[3] = Msp430TimerC.Compare0_A3;

  Msp430Timer[4] = Msp430TimerC.Timer0_A;
  Msp430TimerControl[4] = Msp430TimerC.Control0_A4;
  Msp430Compare[4] = Msp430TimerC.Compare0_A4;
}
