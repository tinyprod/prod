/*
 * Copyright (c) 2009-2010 People Power Co.
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
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

/**
 * Assistance with controlling an MSP430XV2 clock/timer infrastructure.
 *
 * This interface provides the ability to configure the DCO, and to
 * individually start and stop the 32KHz and 1MHz timers.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

interface Msp430XV2ClockControl {
  /**
   * Configure the unified clock system for a specified DCO (MCLK)
   * rate.  Generally, the parameter is a value from the
   * Msp430XV2DcoConfig_e enumeration, but non-default implementations
   * may use alternative encodings.
   *
   * This operation can be invoked after startup to change the clock
   * speed (and hence power consumption), though doing so may disrupt
   * timers.  It is recommended that both the 32KHz and Micro timers
   * be stopped while changing the DCO configuration.
   */
  async command void configureUnifiedClockSystem (int dco_config);

  /**
   * Configure the 32KHz (T32Khz) and 1MHz (TMicro) timers
   *
   * Upon completion, the timers are configured but off.  Invoking
   * this will reset the values of hardware timer counters.
   */
  command void configureTimers ();

  /**
   * Start the 32KHz timer.
   *
   * Upon completion of this command, the timer is running in
   * continuous mode.
   *
   * This is normally invoked during platform initialization through
   * Msp430XV2ClockC.Init.
   */
  async command void start32khzTimer ();

  /**
   * Stop the 32KHz timer.
   *
   * Upon completion of this command, the timer is stopped and
   * interrupts are disabled.
   *
   * This is normally never invoked, but might be useful to enter
   * really low-power modes.
   */
  async command void stop32khzTimer ();

  /** Return TRUE iff T32khz is running. */
  async command bool is32khzTimerRunning ();

  /**
   * Start the 1MHz timer.
   *
   * Upon completion of this command, the timer is running in
   * continuous mode.
   *
   * This is normally invoked during platform initialization through
   * Msp430XV2ClockC.Init.  It may be invoked in certain cases upon
   * return from a low power mode for which the timer was disabled.
   *
   * It is safe to invoke this while the timer is running; do so will
   * not affect the running system.
   */
  async command void startMicroTimer ();

  /**
   * Stop the 1MHz timer.
   *
   * Upon completion of this command, the timer is stopped.
   *
   * Certain MSP430 chips will not enter the requested low power modes
   * if a running timer depends on SMCLK (which is often used as
   * TMicro).  Use of this command can temporarily turn off the
   * timers.  It is safe to re-invoke this operation while the timer
   * is stopped.
   *
   * @note While TMicro is stopped, certain facilities such as
   * BusyWaitMicro will not work.
   */
  async command void stopMicroTimer ();

  /** Return TRUE iff TMicro is running. */
  async command bool isMicroTimerRunning ();
}
