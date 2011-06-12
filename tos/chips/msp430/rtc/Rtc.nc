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

/**
 * @author David Moss
 */

interface Rtc {

  /**
   * RTC was updated
   */
  async event void fired();

  /**
   * Use binary coded decimal instead of hex
   * @param useBcd TRUE to report units in BCD, FALSE to report units in hex
   */
  command void setBcd(bool useBcd);

  /**
   * @return TRUE if we're using BCD, FALSE if we're using Hex
   */
  command bool isBcd();

  /**
   * @return TRUE if values are safe to read, FALSE if they're not
   */
  command bool isReady();

  /**
   * Hex : [0][0][seconds 0 to 59]
   * BCD : [0][3: Seconds - high digit 0 to 5][4: Seconds - low digit 0 to 9]
   * @return seconds
   */
  command uint8_t getSecond();

  /**
   * Hex : [0][0][minutes 0 to 59]
   * BCD : [0][3: minutes - high digit 0 to 5][4: minutes - low digit 0 to 9]
   * @return minutes
   */
  command uint8_t getMinute();

  /**
   * Hex : [0][0][0][hours 0 to 24]
   * BCD : [0][0][2: hours - high digit 0 to 2][4: hours - low digit 0 to 9]
   * @return hours
   */
  command uint8_t getHour();

  /**
   * [0][0][0][0][0][day of week 0 to 6]
   * @return the day of the week
   */
  command uint8_t getDayOfWeek();

  /**
   * Hex : [0][0][0][day of month 1 to 28, 29, 30, 31]
   * BCD : [0][0][2: d.o.m. - high digit 0 to 3][4: d.o.m - low digit 0 to 9]
   * @return the day of the month
   */
  command uint8_t getDayOfMonth();

  /**
   * Hex : [0][0][0][0][month 1 to 12]
   * BCD : [0][0][0][1: month - high digit 0 to 3][4: month - low digit 0 to 9]
   * @return the month
   */
  command uint8_t getMonth();

  /**
   * Hex : [8: year - low byt of 0 to 4095]
   * BCD : [4: decade 0 to 9][4: year - lowest digit 0 to 9]
   * @return the year low-byte
   */
  command uint8_t getYearL();

  /**
   * Hex : [0][0][0][0][4: year - high byte of 0 to 4095]
   * BCD : [0][3: century - high digit 0 to 4][4: century - low digit 0 to 9]
   * @return the year high-byte
   */
  command uint8_t getYearH();

  /**
   * Hex : [0][0][seconds 0 to 59]
   * BCD : [0][3: Seconds - high digit 0 to 5][4: Seconds - low digit 0 to 9]
   * @param second The current second
   */
  command void setSecond(uint8_t second);

  /**
   * Hex : [0][0][minutes 0 to 59]
   * BCD : [0][3: minutes - high digit 0 to 5][4: minutes - low digit 0 to 9]
   * @param minute The current minute
   */
  command void setMinute(uint8_t minute);

  /**
   * Hex : [0][0][0][hours 0 to 24]
   * BCD : [0][0][2: hours - high digit 0 to 2][4: hours - low digit 0 to 9]
   * @param hour The current hour
   */
  command void setHour(uint8_t hour);

  /**
   * [0][0][0][0][0][day of week 0 to 6]
   * @param dayOfWeek the current day of the week
   */
  command void setDayOfWeek(uint8_t dayOfWeek);

  /**
   * Hex : [0][0][0][day of month 1 to 28, 29, 30, 31]
   * BCD : [0][0][2: d.o.m. - high digit 0 to 3][4: d.o.m - low digit 0 to 9]
   * @param dayOfMonth the current day of the month
   */
  command void setDayOfMonth(uint8_t dayOfMonth);

  /**
   * Hex : [0][0][0][0][month 1 to 12]
   * BCD : [0][0][0][1: month - high digit 0 to 3][4: month - low digit 0 to 9]
   * @param month the current month
   */
  command void setMonth(uint8_t month);

  /**
   * Hex : [8: year - low byt of 0 to 4095]
   * BCD : [4: decade 0 to 9][4: year - lowest digit 0 to 9]
   * @param yearL the current year low-byte
   */
  command void setYearL(uint8_t yearL);

  /**
   * Hex : [0][0][0][0][4: year - high byte of 0 to 4095]
   * BCD : [0][3: century - high digit 0 to 4][4: century - low digit 0 to 9]
   * @param yearH the current year high-byte
   */
  command void setYearH(uint8_t yearH);
}
