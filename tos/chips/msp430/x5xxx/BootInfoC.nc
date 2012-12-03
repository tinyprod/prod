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

#include <stdio.h>

/** Display reset codes on an MSP430 supporting the SYSRSTIV register.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

module BootInfoC {
  provides interface Init;
} implementation {

  typedef struct vector_t {
      uint16_t value;
      char* description;
  } vector_t;

  static const vector_t reset_types[] = {
    { 0x0000, "None" },
    { 0x0002, "Brownout" },
    { 0x0004, "RST#/NMI" },
    { 0x0006, "PMMSWBOR" },
    { 0x0008, "Wake from LPM5" },
    { 0x000a, "Security violation" },
    { 0x000c, "SVSL" },
    { 0x000e, "SVSH" },
    { 0x0010, "SVML_OVP" },
    { 0x0012, "SVMH_OVP" },
    { 0x0014, "PMMSWPOR" },
    { 0x0016, "WDT timeout" },
    { 0x0018, "WDT key violation" },
    { 0x001a, "KEYV flash key violation" },
    { 0x001c, "PLL unlock" },
    { 0x001e, "PERF peripheral/configuration area fetch" },
    { 0x0020, "PMM key violation" },
    { 0, 0 }
  };

  command error_t Init.init () {
    uint16_t iv = SYSRSTIV;
    if (0 != iv) {
      printf("*** RESET DATA:\r\n");
      do {
        const vector_t* vp = reset_types;
        while ((vp->value != iv) && vp->description) {
          ++vp;
        }
        printf(" %02x (%s)\r\n", iv, vp->description ?: "UNRECOGNIZED");
        iv = SYSRSTIV;
      } while (0 != iv);
    }
    return SUCCESS;
  }
}
