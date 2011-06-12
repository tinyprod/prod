/**
 * @author David Moss
 */

#ifndef RTC_H
#define RTC_H

/**
 * Real-Time Clock Control Register 1 Bit Positions
 */
enum rtcctl1_e {
  RTCCTL1_RTCBCD = 7,
  RTCCTL1_RTCHOLD = 6,
  RTCCTL1_RTCMODE = 5,
  RTCCTL1_RTCRDY = 4,
  RTCCTL1_RTCSSEL = 2,
  RTCCTL1_RTCTEV = 0,
};

/**
 * Real-Time Clock Control 0 Register Bit Positions
 */
enum rtcctl0_e {
  RTCCTL0_RTCTEVIE = 6,
  RTCCTL0_RTCAIE = 5,
  RTCCTL0_RTCRDYIE = 4,

  RTCCTL0_RTCTEVIFT = 2,
  RTCCTL0_RTCAIFG = 1,
  RTCCTL0_RTCRDYIFG = 0,
};

enum rtc_alarm_e {
  RTC_ENABLE_ALARM = 0x80,
};

#endif
