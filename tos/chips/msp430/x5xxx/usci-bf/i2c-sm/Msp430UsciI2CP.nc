/*
 * Copyright (c) 2012 Eric B. Decker
 * Copyright (c) 2011 John Hopkins University
 * Copyright (c) 2011 Redslate Ltd.
 * Copyright (c) 2009-2010 People Power Co.
 * All rights reserved.
 *
 * Single Master driver.
 *
 * This open source code was developed with funding from People Power Company
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
 *
 *
 * Implement the I2C-related interfaces for a MSP430 USCI module
 * instance.   Single Master.
 *
 * Started with the John Hopkins Multi-Master i2c driver and then
 * optimized for Single Master.
 *
 * @author Eric B. Decker <cire831@gmail.com>
 * @author Doug Carlson   <carlson@cs.jhu.edu>
 * @author Marcus Chang   <marcus.chang@gmail.com>
 * @author Peter A. Bigot <pab@peoplepowerco.com> 
 * @author Derek Baker    <derek@red-slate.com>
 */

#include <stdio.h>
#include "msp430usci.h"
#include <I2C.h>

generic module Msp430UsciI2CP () @safe() {
  provides {
    interface I2CPacket<TI2CBasicAddr> as I2CBasicAddr[uint8_t client];
    interface I2CSlave[uint8_t client];
    interface ResourceConfigure[uint8_t client];
    interface Msp430UsciError[uint8_t client];
  }
  uses {
    interface HplMsp430Usci as Usci;
    interface HplMsp430UsciInterrupts as Interrupts;
    interface HplMsp430GeneralIO as SDA;
    interface HplMsp430GeneralIO as SCL;
    interface Msp430UsciConfigure[uint8_t client];
    interface ArbiterInfo;
    interface LocalTime<TMilli> as LocalTime_bms;
  }
}

implementation {
  enum{
    SLAVE = 0,
    MASTER_READ = 1,
    MASTER_WRITE = 2,
  };

  norace uint8_t* m_buf;
  norace uint8_t m_len;
  norace uint8_t m_pos;
  norace uint8_t m_action;
  norace i2c_flags_t m_flags;

  void nextRead();
  void nextWrite();
  void signalDone( error_t error );

  error_t configure_(const msp430_usci_config_t* config){
    if(! config){
      return FAIL;
    }
    call Usci.configure(config, TRUE);
    call SCL.selectModuleFunc();
    call SDA.selectModuleFunc();
    call Usci.leaveResetMode_();
    return SUCCESS;
  }


  /*
   * We assume that SCL/SDA are initially set up as input so when
   * we deselect the pins from the module, the pins go back to inputs.
   * The module is kept in reset.   This configuration should be
   * reasonable for lowish power.
   */
  error_t unconfigure_(){
    call Usci.enterResetMode_();
    call SCL.selectIOFunc();
    call SDA.selectIOFunc();
    return SUCCESS;
  }

  async command void ResourceConfigure.configure[ uint8_t client ]() {
    configure_(call Msp430UsciConfigure.getConfiguration[client]());
  }

  async command void ResourceConfigure.unconfigure[ uint8_t client ]() {
    unconfigure_();
  }

  /*************************************************************************/

  async command error_t I2CBasicAddr.read[uint8_t client]( i2c_flags_t flags,
					   uint16_t addr, uint8_t len, 
					   uint8_t* buf ) {

    //According to TI, we can just poll until the start condition
    //clears.  But we're nervous and want to bail out if it doesn't
    //clear fast enough.  This is how many times we loop before we
    //bail out.

    uint16_t counter = I2C_ONE_BYTE_READ_COUNTER;

    m_buf = buf;
    m_len = len;
    m_flags = flags;
    m_pos = 0;
    m_action = MASTER_READ;

    /* check if this is a new connection or a continuation */
    if (m_flags & I2C_START) {
      call Usci.setI2Csa(addr);

      //check bus status at the latest point possible.
      if ( call Usci.getStat() & UCBBUSY ) {
	/*
	 * If the bus is busy, that is real weird.   We are single
	 * master.   Just signal a timeout.   Later.   FIXME.
	 */
        return EBUSY;
      }

      // clear TR bit (receiving), set start condition
      call Usci.setCtl1((call Usci.getCtl1() & ~UCTR)  | UCTXSTT);

      // enable nack and rx interrupts only
      call Usci.setIe(UCNACKIE | UCRXIE);

      /*
       * if only reading 1 byte, STOP bit must be set right after
       * START condition is triggered
       */
      if ( (m_len == 1) && (m_flags & I2C_STOP) ) {
        //this logic seems to work fine
        /* wait until START bit has been transmitted */
        while ((call Usci.getCtl1() & UCTXSTT) && (counter > 0x01)){
          counter--;
        }
        call Usci.setCtl1(call Usci.getCtl1() | UCTXSTP);
      }
    } else if (m_flags & I2C_RESTART) {
      /* set slave address */
      call Usci.setI2Csa(addr);

      /*
       * clear TR (receive), generate START
       */
      call Usci.setCtl1((call Usci.getCtl1() & ~UCTR) | UCTXSTT);

      // enable nack and rx only
      call Usci.setIe(UCNACKIE | UCRXIE);

      /* if only reading 1 byte, STOP bit must be set right after START bit */
      if ( (m_len == 1) && (m_flags & I2C_STOP) ) {
        /* wait until START bit has been transmitted */
        while ((call Usci.getCtl1() & UCTXSTT) && (counter > 0x01)){
          counter--;
        }
        call Usci.setCtl1(call Usci.getCtl1() | UCTXSTP);
      }
    } else {
      //TODO: test
      nextRead();
    }
    if (counter > 1)
      return SUCCESS;    

    return FAIL;
  }

  void nextRead() {
    uint16_t counter = 0xFFFF;

    if ((m_pos == (m_len - 2)) && m_len > 1) {
      //we want to send NACK + STOP in response to the last byte.
      //if m_pos == m_len-2 and we get the RX interrupt, that means
      //  that the slave has already written the next-to-last byte
      //  and we have acknowledged it--BUT we have not yet read it.
      //By setting the stop condition here, we say "send STOP after
      //the next byte," which will actually be the last byte.
      //
      //it is more intuitive to say "read the next-to-last byte and
      //set the STOP condition real quick before the last byte gets
      //sent so that we can NACK+STOP it". Maybe this would work if
      //you slowed down the I2C clock enough?
      call Usci.setCtl1(call Usci.getCtl1() | UCTXSTP);
    }
    /* read byte from RX buffer */
    m_buf[ m_pos++ ] = call Usci.getRxbuf();

    //TODO: this should check m_flags: if RESTART flag is present, we
    //should not send stop condition
    if (m_pos == m_len) {

      //when we receive the last byte, wait until STP condition is
      //cleared, then return.
      while( (call Usci.getCtl1() & UCTXSTP) && (counter > 0x01)) {
        counter --;
      }

      //disable the rx interrupt 
      call Usci.setIe(call Usci.getIe() & ~UCRXIE);
      if (counter > 0x01) {
        signal I2CBasicAddr.readDone[call ArbiterInfo.userId()]( SUCCESS, call Usci.getI2Csa(), m_pos, m_buf );
      } else {
        signal I2CBasicAddr.readDone[call ArbiterInfo.userId()]( FAIL, call Usci.getI2Csa() , m_pos, m_buf );
      }
    }
  }
  
  async command error_t I2CBasicAddr.write[uint8_t client]( i2c_flags_t flags,
					    uint16_t addr, uint8_t len,
					    uint8_t* buf ) {
    m_buf = buf;
    m_len = len;
    m_flags = flags;
    m_pos = 0;
    m_action = MASTER_WRITE;

    /* check if this is a new connection or a continuation */
    if (m_flags & I2C_START) {
      /*
       * Original "gen 1" driver was written for the x2 and implements
       * i2c as described in x2 User_Manual (slau144, rev H).
       *
       * x5 i2c master is described in slau208, section 34.3.4.2.1.
       *
       * Sequence:
       *
       * - set sa
       * - set UCTR  (transmit, write)
       * - set UCTXSTT (start)
       *
       * (start/address written, then we get an interrupt), for TXIFG
       *
       */
      call Usci.setI2Csa(addr);

      //check bus status at the latest point possible.
      if (call Usci.getStat() & UCBBUSY) {
	/*
	 * If the bus is busy, that is real weird.   We are single
	 * master.   Just signal a timeout.   Later.   FIXME.
	 */
        return EBUSY;
      }

      call Usci.setCtl1(call Usci.getCtl1() | UCTR | UCTXSTT);

      /*
       * enable relevant state interrupts and TX, clear the rest
       */

//    while ( call Usci.getCtl1() & UCTXSTT) {}

      call Usci.setIe(UCNACKIE | UCTXIE);
    } 
    /* is this a restart or a direct continuation */
    else if (m_flags & I2C_RESTART) {
      // set slave address 
      call Usci.setI2Csa(addr);

      /* UCTR - set transmit */
      /* UCTXSTT - generate START condition */
      call Usci.setCtl1(call Usci.getCtl1() | UCTR | UCTXSTT);
      //do we not need to enable any interrupts here?
    } else {
      // continue writing next byte 
      nextWrite();
    }
    return SUCCESS;    
  }

  void nextWrite() {
    uint16_t counter = 0xFFFF;

    //Hey, now here's a fun thing to do:
    //  It seems like if two masters set START at almost the same
    //  time, they both get the TX interrupt, so both write their 0th
    //  byte into the TX buffer. However, only one of them actually
    //  writes it out, and no arbitration-loss interrupt is raised for
    //  the "slow" one. When the "fast" one finishes its transaction,
    //  the slow one gets a second TX interrupt, which would cause us
    //  to skip over the first byte by accident. This checks for the
    //  issue and rewinds the buffer position to 0 if it applies.  I
    //  make no guarantees about how stable this behavior is.

    if ( call Usci.getCtl1() & UCTXSTT) {
      m_pos = 0;
    }

    /* more bytes to do? */
    if (m_pos < m_len) {
      call Usci.setTxbuf(m_buf[m_pos++]);
      return;
    }
      
    /*
     * all bytes sent
     *
     * if STOPPING, set stop bit.   Not setting stop let's the master
     * to continue with more transactions....
     */
    if ( m_flags & I2C_STOP ) {
      call Usci.setCtl1(call Usci.getCtl1() | UCTXSTP);

      /* wait until STOP bit has been transmitted */
      while ((call Usci.getCtl1() & UCTXSTP) && (counter > 0x01)) {
	counter--;
      }
    }

    // disable tx interrupt, we're DONE 
    call Usci.setIe(call Usci.getIe() & ~UCTXIE );

    signal I2CBasicAddr.writeDone[call ArbiterInfo.userId()](
	(counter > 1) ? SUCCESS : FAIL, call Usci.getI2Csa(), m_len, m_buf);
    return;
  }


  // defaults

  default async event void I2CBasicAddr.readDone[uint8_t client](error_t error, uint16_t addr, uint8_t length, uint8_t* data)  {}

  default async event void I2CBasicAddr.writeDone[uint8_t client](error_t error, uint16_t addr, uint8_t length, uint8_t* data) {}

  default async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration[uint8_t client]() {
    return &msp430_usci_i2c_default_config;
  }


  /***************************************************************************/

  void TXInterrupts_interrupted(uint8_t iv);
  void RXInterrupts_interrupted(uint8_t iv);
  void NACK_interrupt();

  async event void Interrupts.interrupted(uint8_t iv) {
    switch(iv) {
      case USCI_I2C_UCNACKIFG:
        NACK_interrupt();
        break;
      case USCI_I2C_UCRXIFG:
        RXInterrupts_interrupted(iv);
        break;
      case USCI_I2C_UCTXIFG:
        TXInterrupts_interrupted(iv);
        break;
      default:
        //error
        break;
    }
  }

  void TXInterrupts_interrupted(uint8_t iv) {
    nextWrite();
  }

  void RXInterrupts_interrupted(uint8_t iv) {
    nextRead();
  }

  void NACK_interrupt() {
    uint8_t counter = 0xff;

    /*
     * This occurs during write and read when no ack is received.
     *
     * set stop bit
     */
    call Usci.setCtl1(call Usci.getCtl1() | UCTXSTP);

    /* wait until STOP bit has been transmitted */
    while ((call Usci.getCtl1() & UCTXSTP) && (counter > 0x01)) {
      counter--;
    }
    call Usci.enterResetMode_();
    call Usci.leaveResetMode_();

    /*
     * signal appropriate event depending on whether we were
     * transmitting or receiving
     *
     * Note that UCTR will be cleared if we lost MM arbitration because
     *
     * another master addressed us as a slave. However, this should
     * manifest as an AL interrupt, not a NACK interrupt.
     */
    if (call Usci.getCtl1() & UCTR) {
      signal I2CBasicAddr.writeDone[call ArbiterInfo.userId()]( ENOACK, call Usci.getI2Csa(), m_len, m_buf );
    } else {
      signal I2CBasicAddr.readDone[call ArbiterInfo.userId()]( ENOACK, call Usci.getI2Csa(), m_len, m_buf );
    }
  }


  /*
   * No Slave interfaces actually implemented.   We are Single Master only.  We are always the
   * master...   To avoid having to mess with the wiring from the main usci directory (auto-generated
   * modules, we simply stub out the Slave interfaces.
   */
	command error_t I2CSlave.setOwnAddress[uint8_t client](uint16_t addr)	{ return FAIL; }
	command error_t I2CSlave.enableGeneralCall[uint8_t client]()		{ return FAIL; }
	command error_t I2CSlave.disableGeneralCall[uint8_t client]()		{ return FAIL; }
  async command uint8_t I2CSlave.slaveReceive[uint8_t client]()			{ return 0; }
  async command void	I2CSlave.slaveTransmit[uint8_t clientId](uint8_t data)	{}

#ifdef notdef
  default async event bool I2CSlave.slaveReceiveRequested[uint8_t client]()	{ return FALSE; }
  default async event bool I2CSlave.slaveTransmitRequested[uint8_t client]()	{ return FALSE; }

  default async event void I2CSlave.slaveStart[uint8_t client](bool isGeneralCall) { ; }
  default async event void I2CSlave.slaveStop[uint8_t client]()			{ ; }
#endif
}
