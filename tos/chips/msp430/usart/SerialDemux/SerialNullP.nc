/*
 * Copyright (c) 2008 Eric B. Decker
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
 * - Neither the name of the Stanford University nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL STANFORD
 * UNIVERSITY OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author Eric B. Decker (cire831@gmail.com)
 * @date 28 May 2008
 */

module SerialNullP {
  provides interface Init;
  uses {
    interface ResourceDefaultOwner as SerialDefOwner;
    interface AsyncStdControl;

    interface ResourceDefaultOwner as MuxDefOwner;
    interface ResourceDefaultOwnerMux as MuxControl;
  }
}

implementation {

  void serial_shutdown() {
    mmP5out.ser_sel = SER_SEL_NONE;
    call AsyncStdControl.stop();
  }

  void serial_turnon() {
    call AsyncStdControl.start();
  }

  /*
   * When we first start out the SerialDemuxResource is owned by its
   * DefaultOwner (MuxDefOwner).  The h/w state should be off.
   */
  command error_t Init.init() {
    serial_shutdown();
    return SUCCESS;
  }

  async event void MuxDefOwner.granted() {
    call MuxControl.set_mux(SERIAL_OWNER_NULL);
    if (call SerialDefOwner.isOwner())
      serial_shutdown();
  }

  async event void MuxDefOwner.requested() {
    call MuxDefOwner.release();
  }

  async event void MuxDefOwner.immediateRequested() {
    call MuxDefOwner.release();
  }

  async event void SerialDefOwner.requested() {
    serial_turnon();
    call SerialDefOwner.release(); 
  }

  async event void SerialDefOwner.immediateRequested() {
    call AsyncStdControl.start();
    call SerialDefOwner.release();
  } 

  async event void SerialDefOwner.granted() {
    serial_shutdown();
  }
}
