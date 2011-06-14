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

interface RtcAlarm {

  /**
   * Start the RTC alarm
   */
  command void start();

  /**
   * Stop the alarm without clearing the settings
   */
  command void stop();

  /**
   * Clear the alarm settings and stop the alarm
   */
  command void clear();

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
   * The alarm fired
   */
  async event void fired();
}
