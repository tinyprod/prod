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
 */

/** Common types and definitions used throughout the RF1A module.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

#ifndef _Rf1a_h_
#define _Rf1a_h_

/** The unique() key to identify individual RF1A modules, should a
 * chip ever support more than one.
 */
#define UQ_MSP430_RF1A "Msp430.Rf1a"

/** The unique() key to identify clients of an RF1A module instance. */
#define UQ_RF1A_CLIENT "Msp430.0.Rf1a"

/** The type used to represent RF1A status */
typedef uint8_t rf1a_status_t;

/** Enumeration values relevant to RF1A status.
 *
 * Most of the values represent bits 6 through 4 of the RF1A status
 * byte, extracted by using the RF1A_S_MASK mask.  A radio that is
 * offline (clock is not stable) is represented by RF1A_S_OFFLINE.
 */

typedef enum rf1a_status_e{
  RF1A_S_MASK =             0x70,
  RF1A_S_FIFOMASK =         0x0F,
  RF1A_S_IDLE =             0x00,
  RF1A_S_RX =               0x10,
  RF1A_S_TX =               0x20,
  RF1A_S_FSTXON =           0x30,
  RF1A_S_CALIBRATE =        0x40,
  RF1A_S_SETTLING =         0x50,
  RF1A_S_RXFIFO_OVERFLOW =  0x60,
  RF1A_S_TXFIFO_UNDERFLOW = 0x70,
  RF1A_S_OFFLINE          = 0xFF,
} rf1a_status_e;

#endif // _Rf1a_h_
