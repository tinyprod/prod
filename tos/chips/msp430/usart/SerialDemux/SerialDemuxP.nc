/**
 * Copyright @ 2008-2010 Eric B. Decker
 * @author Eric B. Decker
 */

#include "serial_demux.h"

module SerialDemuxP {
  provides {
    interface UartByte                as SerialClientUartByte[uint8_t client_id];
    interface UartStream              as SerialClientUartStream[uint8_t client_id];
    interface ResourceDefaultOwner    as SerialDefOwnerClient[uint8_t client_id];
    interface ResourceDefaultOwnerMux as MuxControl;
    interface ResourceDefaultOwnerInfo;
  }

  uses {
    interface ResourceDefaultOwner;
    interface UartByte;
    interface UartStream;
    interface Panic;
  }
}

implementation {
  norace uint8_t serial_defowner = 0;

  void sdm_warn(uint8_t where, uint16_t p) {
    call Panic.warn(PANIC_COMM, where, p, 0, 0, 0);
  }

  async command error_t SerialClientUartByte.send[ uint8_t client_id ]( uint8_t data ) {
    if (serial_defowner != client_id) {
      sdm_warn(1, client_id);
      return FAIL;
    }
    return call UartByte.send(data);
  }

  async command error_t SerialClientUartByte.receive[ uint8_t client_id ]( uint8_t* byte, uint8_t timeout ) {
    if (serial_defowner != client_id) {
      sdm_warn(2, client_id);
      return FAIL;
    }
    return call UartByte.receive(byte, timeout);
  }

  async event void UartStream.receivedByte(uint8_t byte) {
    signal SerialClientUartStream.receivedByte[serial_defowner](byte);
  }
  
  async command error_t SerialClientUartStream.enableReceiveInterrupt[ uint8_t client_id ]() {
    if (serial_defowner != client_id) {
      sdm_warn(3, client_id);
      return FAIL;
    }
    return call UartStream.enableReceiveInterrupt();
  }
  
  async command error_t SerialClientUartStream.disableReceiveInterrupt[ uint8_t client_id ]() {
    if (serial_defowner != client_id) {
      sdm_warn(4, client_id);
      return FAIL;
    }
    return call UartStream.disableReceiveInterrupt();
  }

  async command error_t SerialClientUartStream.receive[ uint8_t client_id ]( uint8_t* buf, uint16_t len ) {
    if (serial_defowner != client_id) {
      sdm_warn(5, client_id);
      return FAIL;
    }
    return call UartStream.receive(buf, len);
  }

  async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {
    signal SerialClientUartStream.receiveDone[serial_defowner](buf, len, error);
  }
  
  async command error_t SerialClientUartStream.send[ uint8_t client_id ]( uint8_t* buf, uint16_t len ) {
    if (serial_defowner != client_id) {
      sdm_warn(6, client_id);
      return FAIL;
    }
    return call UartStream.send(buf, len);
  }

  async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t error) {
    signal SerialClientUartStream.sendDone[serial_defowner](buf, len, error);
  }

  async command error_t MuxControl.set_mux(uint8_t owner) {
    serial_defowner = owner;
    return SUCCESS;
  }

  async command uint8_t MuxControl.get_mux() {
    return serial_defowner;
  }

  async command error_t SerialDefOwnerClient.release[uint8_t client_id]() {
    if (serial_defowner == client_id)
      return call ResourceDefaultOwner.release();
    sdm_warn(7, client_id);
    return FAIL;
  }

  async command bool SerialDefOwnerClient.isOwner[uint8_t client_id]() {
    if (serial_defowner != client_id)
      return FALSE;
    return call ResourceDefaultOwner.isOwner();
  }

  async event void ResourceDefaultOwner.granted() {
    signal SerialDefOwnerClient.granted[serial_defowner]();
  }

  async event void ResourceDefaultOwner.requested() {
    signal SerialDefOwnerClient.requested[serial_defowner]();
  }

  async event void ResourceDefaultOwner.immediateRequested() {
    signal SerialDefOwnerClient.immediateRequested[serial_defowner]();
  }

  async command bool ResourceDefaultOwnerInfo.inUse() {
    return serial_defowner != 0;
  }

  default async event void SerialDefOwnerClient.granted[uint8_t client_id]() {}
  default async event void SerialDefOwnerClient.requested[uint8_t client_id]() {}

  default async event void SerialClientUartStream.sendDone[ uint8_t client_id ](uint8_t* buf, uint16_t len, error_t error) {}
  default async event void SerialClientUartStream.receivedByte[ uint8_t client_id ](uint8_t byte) {}
  default async event void SerialClientUartStream.receiveDone[ uint8_t client_id ]( uint8_t* buf, uint16_t len, error_t error ) {}
}
