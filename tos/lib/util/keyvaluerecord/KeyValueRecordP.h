/*
 * Copyright (c) 2009-2010 People Power Co.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the People Power Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * PEOPLE POWER CO. OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 *
 */

/**
 * Private implementation header for KeyValueRecord.
 *
 * Include this only in the implementation section of
 * KeyValueRecordP.nc and any unit tests that need access to this
 * information.
 * 
 * @author Peter A. Bigot <pab@peoplepowerco.com> */

#ifndef KeyValueRecordP_h_
#define KeyValueRecordP_h_

#include "KeyValueRecord.h"

/** Structure holding a single key/value pair */
typedef struct key_value_record_t {
  /** The key */
  uint16_t key;
  
  /** The value */
  uint16_t value;
} key_value_record_t;

/** Structure holding the history for a single client */
typedef struct client_record_t {
  /** The number of valid entries in the table */
  uint8_t size;
  /** The index of the next table entry to write */
  uint8_t write_index;
  /** The history of records from this client */
  key_value_record_t history[KEYVALUERECORD_HISTORY_SIZE];
} client_record_t;

#endif // KeyValueRecordP_h_
