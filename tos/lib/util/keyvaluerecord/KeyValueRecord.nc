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
 */

/**
 * Maintain a fixed-size FIFO history of key/value pairs on a per-client basis.
 * 
 * @author David Moss
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */
interface KeyValueRecord {

  /**
   * Find out if we've seen this key / value combo got inserted recently
   * 
   * @param key 
   * @param value 
   * @return TRUE if this key value pair was inserted in the log recently
   */
  command bool hasSeen(uint16_t key, uint16_t value);
  
  
  /**
   * Insert a key / value pair into the log
   * @param key
   * @param value
   */
  command void insert(uint16_t key, uint16_t value);

#if WITH_UNIT_TESTS
  /** Make the number of configured clients visible to unit testing. */
  command int numClients_ ();

  /** Make the current size of a specific client's history visible to
   * unit testing. */
  command int historySize_ ();

  /** Make the contents of a specific client's history visible to unit
   * testing. */
  command void* history_ ();

#endif /* WITH_UNIT_TESTS */

}
