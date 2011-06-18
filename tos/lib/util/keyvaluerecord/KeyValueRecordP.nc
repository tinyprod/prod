/* Copyright (c) 2009-2010 People Power Co.
 * All rights reserved.
 *
 * This open source code was developed with funding from People Power Company
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


#include "KeyValueRecord.h"

/**
 * @author David Moss
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */
module KeyValueRecordP {
  provides {
    interface KeyValueRecord[uint8_t client];
  }
}

implementation {

#include "KeyValueRecordP.h"

  enum {
    NUM_CLIENTS = uniqueCount(UQ_KEYVALUERECORD),
  };

  /** History for all clients.
   * @note we rely on zero-initialization of this structure by the
   * comiler or loader. */
  client_record_t client_data[NUM_CLIENTS];
  
  /***************** KeyValueRecord Commands ****************/
  /**
   * Find out if we've seen this key / value combo got inserted recently
   * 
   * @param key 
   * @param value 
   * @return TRUE if this key value pair was inserted in the log recently
   */
  command bool KeyValueRecord.hasSeen[uint8_t client](uint16_t key, uint16_t value) {
    int i;
    client_record_t* crp = client_data + client;
   
    // No history for invalid clients
    if (client >= NUM_CLIENTS) {
      return FALSE;
    }
    for(i = 0; i < crp->size; ++i) {
      key_value_record_t* rp = crp->history + i;
      if ((rp->key == key) && (rp->value == value)) {
        // Match found
        return TRUE;
      }
    }
    // No match in history
    return FALSE;
  }
  
  /**
   * Insert a key / value pair into the log
   * @param key
   * @param value
   */
  command void KeyValueRecord.insert[uint8_t client](uint16_t key, uint16_t value) {
    client_record_t* crp = client_data + client;

    // No history for invalid clients
    if (client >= NUM_CLIENTS) {
      return;
    }
    atomic {
      key_value_record_t* rp = crp->history + crp->write_index;
      rp->key = key;
      rp->value = value;
      // Determine next location to store 
      if (crp->size < (sizeof(crp->history) / sizeof(*crp->history))) {
        crp->size += 1;
        if (crp->size < (sizeof(crp->history) / sizeof(*crp->history))) {
          crp->write_index += 1;
        } else {
          crp->write_index = 0;
        }
      } else {
        crp->write_index = (crp->write_index + 1) % crp->size;
      }
    }
  }

#if WITH_UNIT_TESTS
  command int KeyValueRecord.numClients_[uint8_t client]()
  {
    return NUM_CLIENTS;
  }

  command int KeyValueRecord.historySize_[uint8_t client]()
  {
    if (client >= NUM_CLIENTS) {
      return -1;
    }
    return client_data[client].size;
  }

  command void* KeyValueRecord.history_[uint8_t client]()
  {
    if (client >= NUM_CLIENTS) {
      return 0;
    }
    return client_data[client].history;
  }

#endif // WITH_UNIT_TESTS

}
