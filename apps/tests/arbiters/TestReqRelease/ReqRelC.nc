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
 */
 
/**
 * Please refer to TEP 108 for more information about the components
 * this application is used to test.<br><br>
 */
 
#define TEST_ARBITER_RESOURCE   "Test.Arbiter.Resource"

configuration ReqRelC{ }
implementation {
  components MainC, ReqRelM as App, LedsC,
     new TimerMilliC() as Timer0,
     new TimerMilliC() as Timer1,
     new TimerMilliC() as Timer2,
     new FcfsArbiterC(TEST_ARBITER_RESOURCE) as Arbiter;

  enum {
    R0 = unique(TEST_ARBITER_RESOURCE),
    R1 = unique(TEST_ARBITER_RESOURCE),
    R2 = unique(TEST_ARBITER_RESOURCE),
  };

  App -> MainC.Boot;

  App.Resource0   -> Arbiter.Resource[R0];
  App.R0Requested -> Arbiter.ResourceRequested[R0];
  App.Timer0      -> Timer0;

  App.Resource1   -> Arbiter.Resource[R1];
  App.R1Requested -> Arbiter.ResourceRequested[R1];
  App.Timer1      -> Timer1;

  App.Resource2   -> Arbiter.Resource[R2];
  App.Timer2      -> Timer2;
//  App.R2Requested -> Arbiter.ResourceRequested[R2];

  App.Leds -> LedsC;
}
