/**
 * SerialDemuxC - Configuration to wire up serial demuxing for USART1
 * See tos/chips/msp430/usart/Msp430UsartShare1P.nc for the wiring that
 * causes this module to be invoked by the USART1 arbiter.
 *
 * Copyright @ 2008-2010 Eric B. Decker
 * @author Eric B. Decker
 *
 * This module provides a DefaultOwner Multiplexer intended to sit on top
 * of a shared resource that needs to have different default owners depending
 * on system state.  Only one default owner can be active at a time, and when
 * the underlying arbiter indicates that the default owner should have control
 * of the resource the current client default owner is given the grant.
 *
 * Default Owner clients connect via SerialDefOwnerClient (mux'd ResourceDefaultOwner).
 * Clients must arbritrate for the priviledge of being the default owner via
 * the SerialDemuxResource arbiter.  The SerialDemuxResource also has a default
 * owner (SerialDemuxDefaultOwner) that gets control when no clients wish to have
 * control.  This can be used to power down the serial hardware when no one is
 * actively using it.
 *
 * At the bottom end is a ResourceDefaultOwner interface that connects to the
 * arbiter controlling the underlying resource.  When this arbiter signals
 * ResourceDefaultOwner.granted this event is passed to the controlling
 * client owner or to the SerialDemuxDefaultOwner.
 *
 * Control of the demultiplexer is handled via the ResourceDefaultOwnerMux interface.
 *
 **/

#include "serial_demux.h"
#include "msp430usart.h"

configuration SerialDemuxC {
  provides {
    interface UartByte                as SerialClientUartByte[uint8_t client_id];
    interface UartStream              as SerialClientUartStream[uint8_t client_id];
    interface ResourceDefaultOwner    as SerialDefOwnerClient[uint8_t client_id];
    interface Resource                as SerialDemuxResource[uint8_t client_id];
    interface ResourceDefaultOwner    as SerialDemuxDefaultOwner;
    interface ResourceDefaultOwnerMux as MuxControl;
    interface ResourceDefaultOwnerInfo;
  }

  uses {
    interface ResourceDefaultOwner;
  }
}

implementation {
  components SerialDemuxP;
  SerialClientUartStream   = SerialDemuxP;
  SerialClientUartByte     = SerialDemuxP;
  SerialDefOwnerClient     = SerialDemuxP;
  MuxControl               = SerialDemuxP;
  ResourceDefaultOwnerInfo = SerialDemuxP;

  /*
   * The arbiter that controls the Usart1 resource uses ArbiterP which assigns
   * default_owner_id to be uniqueCount(MSP430_HPLUSART1_RESOURCE).  We use
   * this id to wire in handlers for handling DefaultOwner interrupts.
   */
  components Msp430Uart1P as UartP;
  SerialDemuxP.UartByte   ->   UartP.UartByte[uniqueCount(MSP430_HPLUSART1_RESOURCE)];
  SerialDemuxP.UartStream -> UartP.UartStream[uniqueCount(MSP430_HPLUSART1_RESOURCE)];

  components PanicC;
  SerialDemuxP.Panic -> PanicC;

  components Msp430UsartShare1P as UsartShareP;
  UartP.UsartInterrupts[uniqueCount(MSP430_HPLUSART1_RESOURCE)] -> UsartShareP.Interrupts[uniqueCount(MSP430_HPLUSART1_RESOURCE)];

  components new FcfsArbiterC( SERIAL_DEMUX_RESOURCE ) as SerialDemuxArbiterC;
  SerialDemuxResource      = SerialDemuxArbiterC;
  SerialDemuxDefaultOwner  = SerialDemuxArbiterC;
  ResourceDefaultOwner     = SerialDemuxP;
}
