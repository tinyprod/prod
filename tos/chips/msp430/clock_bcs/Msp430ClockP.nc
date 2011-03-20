/*
 * Copyright (c) 2010-2011 Eric B. Decker
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
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @author Vlado Handziski <handzisk@tkn.tu-berlind.de>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#include "Msp430DcoSpec.h"
#include "Msp430Timer.h"

/*
 * Basic Clock and BC2 differ in the size of the Range Select (RSEL)
 * field.   x1xxx (BASIC_CLOCK) has 3 bits, x2xxx (BC2) has 4 bits.
 * RSEL_MAX denotes where to start for calibration, RSEL_MASK is used
 * to mask the entire RSEL field.
 */
#if defined(__MSP430_HAS_BC2__)
#define RSEL_MASK (RSEL0 | RSEL1 | RSEL2 | RSEL3)
#define RSEL_MAX RSEL3
#elif defined(__MSP430_HAS_BASIC_CLOCK__)
#define RSEL_MASK (RSEL0 | RSEL1 | RSEL2)
#define RSEL_MAX RSEL2
#else
#error "Msp430ClockP (bcs): processor doesn't support BASIC_CLOCK/BC2"
#endif

module Msp430ClockP @safe() {
  provides {
    interface Init;
    interface Msp430ClockInit;
    interface McuPowerOverride;
  }
}

implementation {
  MSP430REG_NORACE(IE1);
  MSP430REG_NORACE(TACTL);
  MSP430REG_NORACE(TAIV);
  MSP430REG_NORACE(TBCTL);
  MSP430REG_NORACE(TBIV);

  enum {
    ACLK_CALIB_PERIOD = 8,
    TARGET_DCO_DELTA = (TARGET_DCO_KHZ / ACLK_KHZ) * ACLK_CALIB_PERIOD,
  };

  async command mcu_power_t McuPowerOverride.lowestState() {
    return MSP430_POWER_LPM3;
  }

  command void Msp430ClockInit.defaultSetupDcoCalibrate() {
    TACTL   = TASSEL_2 | MC_2;		// SMCLK/1, continuous mode, all else 0
    TBCTL   = TBSSEL_1 | MC_2;		// ACLK/1,  continuous
    BCSCTL1 = XT2OFF | RSEL_MAX;
    BCSCTL1 = XT2OFF | RSEL2;
    BCSCTL2 = 0;
    TBCCTL0 = CM0;
  }
    
  command void Msp430ClockInit.defaultInitClocks() {
    // BCSCTL1
    // .XT2OFF = 1; disable the external oscillator for SCLK and MCLK
    // .XTS = 0; set low frequency mode for LXFT1
    // .DIVA = 0; set the divisor on ACLK to 1
    // .XT5V = 0, unused. must be 0
    // .RSEL, do not modify
    BCSCTL1 = XT2OFF | (BCSCTL1 & RSEL_MASK);

    // BCSCTL2
    // .SELM = 0; select DCOCLK as source for MCLK
    // .DIVM = 0; set the divisor of MCLK to 1
    // .SELS = 0; select DCOCLK as source for SCLK
    // .DIVS = 2; set the divisor of SCLK to 4
    // .DCOR = 0; select internal resistor for DCO
    BCSCTL2 = DIVS_2;			/* div/4 */

    // IE1.OFIE = 0; no interrupt for oscillator fault
    CLR_FLAG( IE1, OFIE );
  }

  command void Msp430ClockInit.defaultInitTimerA() {
    TAR = 0;

    // TACTL
    // .TASSEL = 2; source SMCLK = DCO/4
    // .ID = 0; input divisor of 1
    // .MC = 0; initially disabled
    // .TACLR = 0;
    // .TAIE = 1; enable timer A interrupts
    TACTL = TASSEL_2 | TAIE;
  }

  command void Msp430ClockInit.defaultInitTimerB() {
    TBR = 0;

    // TBCTL
    // .TBCLGRP = 0; each TBCL group latched independently
    // .CNTL = 0; 16-bit counter
    // .TBSSEL = 1; source ACLK
    // .ID = 0; input divisor of 1
    // .MC = 0; initially disabled
    // .TBCLR = 0;
    // .TBIE = 1; enable timer B interrupts
    TBCTL = TBSSEL_1 | TBIE;
  }

  default event void Msp430ClockInit.setupDcoCalibrate() {
    call Msp430ClockInit.defaultSetupDcoCalibrate();
  }
  
  default event void Msp430ClockInit.initClocks() {
    call Msp430ClockInit.defaultInitClocks();
  }

  default event void Msp430ClockInit.initTimerA() {
    call Msp430ClockInit.defaultInitTimerA();
  }

  default event void Msp430ClockInit.initTimerB() {
    call Msp430ClockInit.defaultInitTimerB();
  }

  void startTimerA() {
    // TACTL.MC = 2; continuous mode
    TACTL = MC_2 | (TACTL & ~(MC1 | MC0));
  }

  void stopTimerA() {
    // TACTL.MC = 0; stop timer A
    TACTL = TACTL & ~(MC1|MC0);
  }

  void startTimerB() {
    // TBCTL.MC = 2; continuous mode
    TBCTL = MC_2 | (TBCTL & ~(MC1|MC0));
  }

  void stopTimerB() {
    //TBCTL.MC = 0; stop timer B
    TBCTL = TBCTL & ~(MC1|MC0);
  }

  /*
   * dco calibration.
   *
   * dco calibration is done by looking at how many dco clocks via timerA fit
   * into some number of 32768 ACLK periods.  Since we don't know where in a
   * ACLK cycle we are, we must run two cycles.  The 2nd cycle is when we
   * actually do the measurement.
   *
   * Controls for the algorithm behaviour are:
   *
   * From tos/chips/msp430/timer/Msp430DcoSpec.h:
   *	TARGET_DCO_HZ		frequency for DCO, 4096 KiHz
   *	ACLK_HZ			frequency of ACLK, 32768 Hz
   *
   *    ACLK_CALIB_PERIOD = 8,	how many aclk cycles to use for sample period.
   *    TARGET_DCO_DELTA	how many dco (ta) cycles we should see if
   *				calibrated.
   *
   * A calib control cell is passed around to control the algorithm.  This
   * control cell is the concatenation of RSEL (3 bits), DCOx (3 bits), and
   * MODx (5 bits).   Top byte contains RSEL, lower byte DCO and MOD.
   *
   * The key that drives this algorithm is TARGET_DCO_DELTA.  This is the value
   * we look for in a given ACLK_CALIB_PERIOD.  It is computed from
   * TARGET_DCO_HZ and ACLK_HZ.
   */

  void set_dco_calib(uint16_t calib) {
    BCSCTL1 = (BCSCTL1 & ~RSEL_MASK) | ((calib >> 8) & RSEL_MASK);
    DCOCTL  = calib & 0xff;
  }

  uint16_t test_calib_busywait_delta(uint16_t calib) {
    uint16_t aclk_count = 2;		/* better code */
    uint16_t dco_prev   = 0;
    uint16_t dco_curr   = 0;

    set_dco_calib(calib);

    /*
     * Don't know where in the current 32Khz cycle we are so we run two
     * cycles.
     */
    while (aclk_count-- > 0) {
      TBCCR0 = TBR + ACLK_CALIB_PERIOD;		// set next interrupt
      TBCCTL0 &= ~CCIFG;			// clear pending interrupt
      while((TBCCTL0 & CCIFG) == 0)		// busy wait
	;
      dco_prev = dco_curr;
      dco_curr = TAR;
    }
    return dco_curr - dco_prev;
  }

  /*
   * busyCalibrateDCO
   *
   * Should take about 9ms if ACLK_CALIB_PERIOD 8.
   * DCOCTL and BCSCTL1 are calibrated when done.
   * (9ms needs to be verified).  1611 and 2618.
   */
  void busyCalibrateDco() {
    uint16_t calib;
    uint16_t step;

    /*
     * Binary search for RSEL,DCO,DCOMOD.
     * It's okay that RSEL isn't monotonic.
     *
     * RSEL_MAX is 8 for the 2618 and 4 for the 1611.  So step starts
     * with either 0x0800 or 0x0400.
     */
    for (calib = 0, step = RSEL_MAX << 8; step; step >>= 1) {
      /* if the step is not past the target, keep it */
      if (test_calib_busywait_delta(calib | step) <= TARGET_DCO_DELTA)
        calib |= step;
      /*
       * if dco is 7 then mod bits remain zero they don't do anything if
       * dco is 7.  stop.
       */
      if ((calib & 0x0e0) == 0x0e0)
	break;
    }
    set_dco_calib( calib );
  }

  command error_t Init.init() {
    TACTL = TACLR;			/* clear should wack the IVs */
    TBCTL = TBCLR;

    atomic {
      signal Msp430ClockInit.setupDcoCalibrate();
      busyCalibrateDco();
      signal Msp430ClockInit.initClocks();
      signal Msp430ClockInit.initTimerA();
      signal Msp430ClockInit.initTimerB();
      startTimerA();
      startTimerB();
    }
    return SUCCESS;
  }
}
