/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
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

/** 
 * This layer keeps a history of the past RECEIVE_HISTORY_SIZE received messages
 * If the source address and dsn number of a newly received message matches
 * our recent history, we drop the message because we've already seen it.
 *
 * @author David Moss
 */

module UniqueReceiveP {
  provides {
    interface Receive;
    interface Receive as DuplicateReceive;
  }
  uses {
    interface Receive as SubReceive;
    interface KeyValueRecord;
  }
}

implementation {

  /** Convenience typedef denoting the structure used as a physical
   * layer header. */
  typedef rf1a_ieee154_t header_t;

  /** Get a cast pointer to the physical layer header */
  header_t* header (message_t* msg) { return -1 + (header_t*)msg->data; }

  /***************** SubReceive Events *****************/
  event message_t *SubReceive.receive(message_t* msg, void* payload, 
      uint8_t len) {
    header_t* hp = header(msg);
    uint16_t msgSource = hp->src;
    uint8_t msgDsn = hp->dsn;

    if(call KeyValueRecord.hasSeen(msgSource, msgDsn)) {
      return signal DuplicateReceive.receive(msg, payload, len);
    }
    call KeyValueRecord.insert(msgSource, msgDsn);
    return signal Receive.receive(msg, payload, len);
  }

  /***************** Defaults ****************/
  default event message_t *DuplicateReceive.receive(message_t *msg, void *payload, uint8_t len) {
    return msg;
  }
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
