/* 
 * Copyright (c) 2009-2010 People Power Company
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


#if !defined(__MSP430_HAS_RTC__)
#error "Msp430RtcP: processor not supported, need RTC"
#endif

#include "Rtc.h"

/**
 * TODO Year should be a single 16-bit number
 *
 * @author David Moss
 * @author Peter Bigot
 */

module RtcP {
  provides {
    interface Init;
    interface StdControl;
    interface Rtc;
    interface RtcAlarm;
  }
}

implementation {

  /** The rtc interrupt vector contents from the last async interrupt event */
  volatile uint8_t rtciv;

  /***************** Prototypes ****************/
  bool ready();
  task void rtcInterruptHandler();

  /***************** Init Commands ****************/
  command error_t Init.init() {
    RTCCTL1 = (1 << RTCCTL1_RTCMODE);
    return SUCCESS;
  }

  /***************** StdControl Commands ****************/
  command error_t StdControl.start() {
    RTCCTL1 = (RTCCTL1 & ~(1 << RTCCTL1_RTCHOLD));
    RTCCTL0 |= (1 << RTCCTL0_RTCRDYIE);
    return SUCCESS;
  }

  command error_t StdControl.stop() {
    RTCCTL1 &= ~(1 << RTCCTL1_RTCHOLD);
    return SUCCESS;
  }

  /***************** Rtc Commands ****************/

  /**
   * Use binary coded decimal instead of hex
   * @param useBcd TRUE to report units in BCD, FALSE to report units in hex
   */
  command void Rtc.setBcd(bool useBcd) {
    RTCCTL1 = (RTCCTL1 & ~(1 << RTCCTL1_RTCBCD)) | (useBcd << RTCCTL1_RTCBCD);
  }

  /**
   * @return TRUE if we're using BCD, FALSE if we're using Hex
   */
  command bool Rtc.isBcd() {
    return (RTCCTL1 >> RTCCTL1_RTCBCD) & 0x1;
  }

  /**
   * @return TRUE if values are safe to read, FALSE if they're not
   */
  command bool Rtc.isReady() {
    return ready();
  }

  /**
   * Hex : [0][0][seconds 0 to 59]
   * BCD : [0][3: Seconds - high digit 0 to 5][4: Seconds - low digit 0 to 9]
   * @return seconds
   */
  command uint8_t Rtc.getSecond() {
    return RTCSEC;
  }

  /**
   * Hex : [0][0][minutes 0 to 59]
   * BCD : [0][3: minutes - high digit 0 to 5][4: minutes - low digit 0 to 9]
   * @return minutes
   */
  command uint8_t Rtc.getMinute() {
    return RTCMIN;
  }

  /**
   * Hex : [0][0][0][hours 0 to 24]
   * BCD : [0][0][2: hours - high digit 0 to 2][4: hours - low digit 0 to 9]
   * @return hours
   */
  command uint8_t Rtc.getHour() {
    return RTCHOUR;
  }

  /**
   * [0][0][0][0][0][day of week 0 to 6]
   * @return the day of the week
   */
  command uint8_t Rtc.getDayOfWeek() {
    return RTCDOW;
  }

  /**
   * Hex : [0][0][0][day of month 1 to 28, 29, 30, 31]
   * BCD : [0][0][2: d.o.m. - high digit 0 to 3][4: d.o.m - low digit 0 to 9]
   * @return the day of the month
   */
  command uint8_t Rtc.getDayOfMonth() {
    return RTCDAY;
  }

  /**
   * Hex : [0][0][0][0][month 1 to 12]
   * BCD : [0][0][0][1: month - high digit 0 to 3][4: month - low digit 0 to 9]
   * @return the month
   */
  command uint8_t Rtc.getMonth() {
    return RTCMON;
  }

  /**
   * Hex : [8: year - low byt of 0 to 4095]
   * BCD : [4: decade 0 to 9][4: year - lowest digit 0 to 9]
   * @return the year low-byte
   */
  command uint8_t Rtc.getYearL() {
    return RTCYEARL;
  }

  /**
   * Hex : [0][0][0][0][4: year - high byte of 0 to 4095]
   * BCD : [0][3: century - high digit 0 to 4][4: century - low digit 0 to 9]
   * @return the year high-byte
   */
  command uint8_t Rtc.getYearH() {
    return RTCYEARH;
  }

  /**
   * Hex : [0][0][seconds 0 to 59]
   * BCD : [0][3: Seconds - high digit 0 to 5][4: Seconds - low digit 0 to 9]
   * @param second The current second
   */
  command void Rtc.setSecond(uint8_t second) {
    RTCSEC = second;
  }

  /**
   * Hex : [0][0][minutes 0 to 59]
   * BCD : [0][3: minutes - high digit 0 to 5][4: minutes - low digit 0 to 9]
   * @param minute The current minute
   */
  command void Rtc.setMinute(uint8_t minute) {
    RTCMIN = minute;
  }

  /**
   * Hex : [0][0][0][hours 0 to 24]
   * BCD : [0][0][2: hours - high digit 0 to 2][4: hours - low digit 0 to 9]
   * @param hour The current hour
   */
  command void Rtc.setHour(uint8_t hour) {
    RTCHOUR = hour;
  }

  /**
   * [0][0][0][0][0][day of week 0 to 6]
   * @param dayOfWeek the current day of the week
   */
  command void Rtc.setDayOfWeek(uint8_t dayOfWeek) {
    RTCDOW = dayOfWeek;
  }

  /**
   * Hex : [0][0][0][day of month 1 to 28, 29, 30, 31]
   * BCD : [0][0][2: d.o.m. - high digit 0 to 3][4: d.o.m - low digit 0 to 9]
   * @param dayOfMonth the current day of the month
   */
  command void Rtc.setDayOfMonth(uint8_t dayOfMonth) {
    RTCDAY = dayOfMonth;
  }

  /**
   * Hex : [0][0][0][0][month 1 to 12]
   * BCD : [0][0][0][1: month - high digit 0 to 3][4: month - low digit 0 to 9]
   * @param month the current month
   */
  command void Rtc.setMonth(uint8_t month) {
    RTCMON = month;
  }

  /**
   * Hex : [8: year - low byt of 0 to 4095]
   * BCD : [4: decade 0 to 9][4: year - lowest digit 0 to 9]
   * @param yearL the current year low-byte
   */
  command void Rtc.setYearL(uint8_t yearL) {
    RTCYEARL = yearL;
  }

  /**
   * Hex : [0][0][0][0][4: year - high byte of 0 to 4095]
   * BCD : [0][3: century - high digit 0 to 4][4: century - low digit 0 to 9]
   * @param yearH the current year high-byte
   */
  command void Rtc.setYearH(uint8_t yearH) {
    RTCYEARH = yearH;
  }

  /***************** RtcAlarm Commands ****************/
  /**
   * Start the RTC alarm
   */
  command void RtcAlarm.start() {
    RTCCTL0 |= (1 << RTCCTL0_RTCAIE);
  }

  /**
   * Stop the alarm without clearing the settings
   */
  command void RtcAlarm.stop() {
    RTCCTL0 = (RTCCTL0 & ~(1 << RTCCTL0_RTCAIE));
  }

  /**
   * Clear the alarm settings and stop the alarm
   */
  command void RtcAlarm.clear() {
    call RtcAlarm.stop();    
    RTCAMIN = 0;
    RTCAHOUR = 0;
    RTCADOW = 0;
    RTCADAY = 0;
  }

  /**
   * Hex : [0][0][minutes 0 to 59]
   * BCD : [0][3: minutes - high digit 0 to 5][4: minutes - low digit 0 to 9]
   * @param minute The current minute
   */
  command void RtcAlarm.setMinute(uint8_t minute) {
    RTCAMIN = RTC_ENABLE_ALARM | minute;
  }

  /**
   * Hex : [0][0][0][hours 0 to 24]
   * BCD : [0][0][2: hours - high digit 0 to 2][4: hours - low digit 0 to 9]
   * @param hour The current hour
   */
  command void RtcAlarm.setHour(uint8_t hour) {
    RTCAHOUR = RTC_ENABLE_ALARM | hour;
  }

  /**
   * [0][0][0][0][0][day of week 0 to 6]
   * @param dayOfWeek the current day of the week
   */
  command void RtcAlarm.setDayOfWeek(uint8_t dayOfWeek) {
    RTCADOW = RTC_ENABLE_ALARM | dayOfWeek;
  }

  /**
   * Hex : [0][0][0][day of month 1 to 28, 29, 30, 31]
   * BCD : [0][0][2: d.o.m. - high digit 0 to 3][4: d.o.m - low digit 0 to 9]
   * @param dayOfMonth the current day of the month
   */
  command void RtcAlarm.setDayOfMonth(uint8_t dayOfMonth) {
    RTCADAY = RTC_ENABLE_ALARM | dayOfMonth;
  }

  /**
   * Hex : [0][0][minutes 0 to 59]
   * BCD : [0][3: minutes - high digit 0 to 5][4: minutes - low digit 0 to 9]
   * @return minutes
   */
  command uint8_t RtcAlarm.getMinute() {
    return RTCAMIN & 0x7F;
  }

  /**
   * Hex : [0][0][0][hours 0 to 24]
   * BCD : [0][0][2: hours - high digit 0 to 2][4: hours - low digit 0 to 9]
   * @return hours
   */
  command uint8_t RtcAlarm.getHour() {
    return RTCAHOUR & 0x7F;
  }

  /**
   * [0][0][0][0][0][day of week 0 to 6]
   * @return the day of the week
   */
  command uint8_t RtcAlarm.getDayOfWeek() {
    return RTCADOW & 0x7F;
  }

  /**
   * Hex : [0][0][0][day of month 1 to 28, 29, 30, 31]
   * BCD : [0][0][2: d.o.m. - high digit 0 to 3][4: d.o.m - low digit 0 to 9]
   * @return the day of the month
   */
  command uint8_t RtcAlarm.getDayOfMonth() {
    return RTCADAY & 0x7F;
  }

  /***************** Interrupts ****************/

  TOSH_SIGNAL(RTC_VECTOR) {
    __bic_SR_register_on_exit(LPM4_bits);

    atomic {
      rtciv = RTCIV;
      post rtcInterruptHandler();
    }   
  }

  /***************** Functions ***************/

  /**
   * @return TRUE if the RTC values can safely be read
   */
  bool ready() {
    return (RTCCTL1 >> RTCCTL1_RTCRDY) & 0x1;
  }

  /**
   * The interrupt handler removes puts us back in synchronous context
   * making it safer to execute code from the application layer.
   */
  task void rtcInterruptHandler() {
    switch(rtciv) {
      case 0: 
        break;                         // No interrupts

      case 2: 
       signal Rtc.fired();
       break;                          // RTCRDYIFG

      case 4: 
        break;                         // RTCEVIFG

      case 6: 
        signal RtcAlarm.fired();
        break;                         // RTCAIFG

      case 8: 
        break;                         // RT0PSIFG

      case 10: 
        break;                         // RT1PSIFG

      case 12: 
        break;                         // Reserved

      case 14: 
        break;                         // Reserved

      case 16: 
        break;                         // Reserved

      default: 
        break;
    }
  }

  /***************** Defaults ****************/
  default async event void RtcAlarm.fired() { }
}
