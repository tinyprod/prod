/*
 * Copyright (c) 2011, Eric B. Decker
 * Copyright (c) 2010, People Power Co.
 * Copyright (c) 2006, Technische Universitaet Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
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
 *
 * @author Jan Hauer <hauer@tkn.tu-berlin.de>
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 * @author Eric B. Decker <cire831@gmail.com>
 * ========================================================================
 */

#include <Msp430Adc12.h> 
configuration Msp430Adc12P 
{ 
  provides {
    interface Resource[uint8_t id]; 
    interface Msp430Adc12SingleChannel as SingleChannel[uint8_t id]; 
    interface Msp430Adc12MultiChannel as MultiChannel[uint8_t id]; 
    interface Msp430Adc12Overflow as Overflow[uint8_t id]; 
    interface AsyncStdControl as DMAExtension[uint8_t id];
  }
} implementation { 
  components Msp430Adc12ImplP, HplAdc12P, MainC, 
             new SimpleRoundRobinArbiterC(MSP430ADC12_RESOURCE) as Arbiter;

  Resource = Arbiter;
  SingleChannel = Msp430Adc12ImplP.SingleChannel;
  MultiChannel= Msp430Adc12ImplP.MultiChannel;
  Overflow = Msp430Adc12ImplP.Overflow;
  DMAExtension = Msp430Adc12ImplP.DMAExtension;
  
  Msp430Adc12ImplP.Init <- MainC;
  Msp430Adc12ImplP.ADCArbiterInfo -> Arbiter;
  Msp430Adc12ImplP.HplAdc12 -> HplAdc12P;

#if ADC12_USE_PLATFORM_ADC
  components PlatformAdcC ;

  Msp430Adc12ImplP.TimerA -> PlatformAdcC.TimerA;
  Msp430Adc12ImplP.ControlA0 -> PlatformAdcC.ControlA0;
  Msp430Adc12ImplP.ControlA1 -> PlatformAdcC.ControlA1;
  Msp430Adc12ImplP.CompareA0 -> PlatformAdcC.CompareA0;
  Msp430Adc12ImplP.CompareA1 -> PlatformAdcC.CompareA1;

  Msp430Adc12ImplP.A0 -> PlatformAdcC.A0;
  Msp430Adc12ImplP.A1 -> PlatformAdcC.A1;
  Msp430Adc12ImplP.A2 -> PlatformAdcC.A2;
  Msp430Adc12ImplP.A3 -> PlatformAdcC.A3;
  Msp430Adc12ImplP.A4 -> PlatformAdcC.A4;
  Msp430Adc12ImplP.A5 -> PlatformAdcC.A5;
#if 6 < ADC12_PINS_AVAILABLE
  Msp430Adc12ImplP.A6 -> PlatformAdcC.A6;
  Msp430Adc12ImplP.A7 -> PlatformAdcC.A7;
#if 8 < ADC12_PINS_AVAILABLE
  Msp430Adc12ImplP.A8 -> PlatformAdcC.A8;
  Msp430Adc12ImplP.A9 -> PlatformAdcC.A9;
  Msp430Adc12ImplP.A10 -> PlatformAdcC.A10;
  Msp430Adc12ImplP.A11 -> PlatformAdcC.A11;
  Msp430Adc12ImplP.A12 -> PlatformAdcC.A12;
  Msp430Adc12ImplP.A13 -> PlatformAdcC.A13;
  Msp430Adc12ImplP.A14 -> PlatformAdcC.A14;
  Msp430Adc12ImplP.A15 -> PlatformAdcC.A15;
#endif /* ADC12_PINS_AVAILABLE : 8 */
#endif /* ADC12_PINS_AVAILABLE : 6 */

#else /* ADC12_USE_PLATFORM_ADC */

#ifdef ADC12_P6PIN_AUTO_CONFIGURE
  components HplMsp430GeneralIOC;
  Msp430Adc12ImplP.A0 -> HplMsp430GeneralIOC.Port60;
  Msp430Adc12ImplP.A1 -> HplMsp430GeneralIOC.Port61;
  Msp430Adc12ImplP.A2 -> HplMsp430GeneralIOC.Port62;
  Msp430Adc12ImplP.A3 -> HplMsp430GeneralIOC.Port63;
  Msp430Adc12ImplP.A4 -> HplMsp430GeneralIOC.Port64;
  Msp430Adc12ImplP.A5 -> HplMsp430GeneralIOC.Port65;
  Msp430Adc12ImplP.A6 -> HplMsp430GeneralIOC.Port66;
  Msp430Adc12ImplP.A7 -> HplMsp430GeneralIOC.Port67;
#endif

#ifdef ADC12_TIMERA_ENABLED
  components Msp430TimerC;
  Msp430Adc12ImplP.TimerA -> Msp430TimerC.TimerA;
  Msp430Adc12ImplP.ControlA0 -> Msp430TimerC.ControlA0;
  Msp430Adc12ImplP.ControlA1 -> Msp430TimerC.ControlA1;
  Msp430Adc12ImplP.CompareA0 -> Msp430TimerC.CompareA0;
  Msp430Adc12ImplP.CompareA1 -> Msp430TimerC.CompareA1;
#endif

#endif /* ADC12_USE_PLATFORM_ADC */
}
