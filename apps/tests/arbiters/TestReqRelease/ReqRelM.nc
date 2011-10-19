/*
 * Copyright (c) 2011, Eric B. Decker
 * Copyright (c) 2004, Technische Universitat Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Technische Universitat Berlin nor the names
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @author Eric B. Decker (cire831@gmail.com)
 */
 
/**
 * This application is used to test the functionality of the
 * FcfsArbiter component developed using the Resource 
 * interface.
 *
 * In particular, this test looks at what happens when a request
 * is coupled to the current owners code via the ResourceRequested
 * interface.   Client0 then releases the resource (which allows the
 * new requester to acquire the resource) and then gets back in line.
 */

#include "Timer.h"
 
module ReqRelM {
  uses {
    interface Boot;  
    interface Leds;

    interface Resource		as Resource0;
    interface ResourceRequested as R0Requested;
    interface Timer<TMilli> as Timer0;

    interface Resource		as Resource1;
    interface ResourceRequested as R1Requested;
    interface Timer<TMilli> as Timer1;

    interface Resource		as Resource2;
//  interface ResourceRequested as R2Requested;
    interface Timer<TMilli> as Timer2;
  }
}
implementation {

  #define HOLD_PERIOD 256
  
  event void Boot.booted() {
    call Resource0.request();
  }

  /*
   * Resource 0 is the main background holder of the resource.
   */
  event void Resource0.granted() {
    call Timer0.startOneShot(HOLD_PERIOD);
    call Leds.led0On();
  }  

  event void Timer0.fired() {
    call Leds.led0Off();
    call Resource1.request();
  }

  task void R0request() {
    call Resource0.request();
  }

  async event void R0Requested.requested() {
    call Resource0.release();
    call Resource0.request();
//    post R0request();
  }

  event void Resource1.granted() {
    call Timer1.startOneShot(HOLD_PERIOD);
    call Leds.led1On();
  }  

  event void Timer1.fired() {
    call Leds.led1Off();
    call Resource2.request();
  }

  task void R1request() {
    call Resource1.request();
  }

  async event void R1Requested.requested() {
    call Resource1.release();
//    post R1request();
//    call Resource1.request();
  }

  event void Resource2.granted() {
    call Timer2.startOneShot(HOLD_PERIOD);
    call Leds.led2On();
  }  

  event void Timer2.fired() {
    call Leds.led2Off();
    call Resource2.release();
  }

#ifdef notdef
  task void R2request() {
    call Resource2.request();
  }

  async event void R2Requested.requested() {
    call Resource2.release();
//    post R2request();
//    call Resource2.request();
  }
#endif

  async event void R0Requested.immediateRequested() { }
  async event void R1Requested.immediateRequested() { }
//  async event void R2Requested.immediateRequested() { }
}
