/*
 * Copyright (c) 2012 Eric B. Decker
 * All rights reserved.
 *
 * Single Master driver.
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
 * Originally started with the Multi-Master i2c driver from John
 * Hopkins (Doug Carlson, et. al.).   Completely rewritten to
 * simplify and verified for proper operation at 400 KHz.  Previous
 * drivers worked at 100 KHz but not at 400 KHz.
 *
 * Optimized for single master.
 *
 * Following research into how the TI MSP430 x5 i2c implementation really
 * works, including observation using a logic analyzer, corrected to
 * obtain correct bus operation (minimizes extra bytes).
 *
 * Written explicitly for 400KHz bus operation assuming small register
 * transactions.   Added I2CReg semantics.  (100Khz is fine too).
 *
 * Uses Panic to call out abnormal conditions.  These conditions are
 * assumed to be out of normal behaviour and aren't recoverable.
 *
 * Uses Platform to obtain raw timing information for timeout functions.
 *
 * WARNING: By default, null versions for both Panic and timing modules are
 * used.  This effectively disables any timeout checks or panic invocations.
 * This preserves the original behaviour and doesn't require changing lots
 * of things all at once.  When a Platform wants to use the new functionality
 * it can wire in the required components.  This is the recommended
 * configuration
 *
 * To enable Panic signalling and timeout functions, you must wire in
 * appropriate routines into Panic and Platform in this module.
 *
 * It is recommended that you define REQUIRE_PLATFORM and REQUIRE_PANIC in
 * your platform.h file.  This will require that appropriate wiring exists
 * for Panic and Platform and is wired in.
 *
 * @author Eric B. Decker <cire831@gmail.com>
 *
 * previous authors...   But it has been completely rewritten.
 *
 * @author Doug Carlson   <carlson@cs.jhu.edu>
 * @author Marcus Chang   <marcus.chang@gmail.com>
 * @author Peter A. Bigot <pab@peoplepowerco.com> 
 * @author Derek Baker    <derek@red-slate.com>
 */

#include "msp430usci.h"
#include <I2C.h>

#ifndef PANIC_I2C

enum {
  __panic_i2c = unique(UQ_PANIC_SUBSYS)
};

#define PANIC_I2C __panic_i2c
#endif

volatile uint8_t bees[32];
uint16_t bees_idx;

typedef struct {
  uint16_t ts;
  uint8_t ctl1;
  uint8_t ifg;
  uint8_t stat;
} usci_reg_t;

void get_state(usci_reg_t *p) {
  p->ts   = TA1R;
  p->ctl1 = UCB3CTL1;
  p->ifg  = UCB3IFG;
  p->stat = UCB3STAT;
}


generic module Msp430UsciI2CP () @safe() {
  provides {
    interface I2CPacket<TI2CBasicAddr> as I2CBasicAddr[uint8_t client];
    interface I2CReg[uint8_t client];
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
    interface Panic;
    interface Platform;
  }
}

implementation {
  enum{
    MASTER_READ = 1,
    MASTER_WRITE = 2,

    /*
     * Time based timeouts.  Given 100 KHz, 400 uS should be plenty, but
     * this doesn't handle clock stretching.  The time out code needs
     * to handle this special.   And still needs to make sure that we
     * don't hang.   While still giving the h/w long enough to complete
     * its bus transaction.
     *
     * For the time being we ignore clock stretching.   Cross that bridge
     * if the troll climbs out from underneath.
     *
     * Timeout is in either uS or uiS depending on what the base clock
     * system is set for.  Just set it high enough so it doesn't matter.
     */
    I2C_MAX_TIME = 400,			/* max allowed, 400 uS (uis) */
  };

#define __PANIC_I2C(where, x, y, z) do { \
	call Panic.panic(PANIC_I2C, where, call Usci.getModuleIdentifier(), \
			 x, y, z); \
	call Usci.enterResetMode_(); \
  } while (0)

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
   * We assume that the pins begin used for SCL/SDA have been set up
   * or left (initial state) as input (DIR set to 0 for the pin).
   * When we deselect the pins from the module, the pins will go
   * back to inputs.  The module itself is kept in reset.   This
   * configuration should be reasonable for lowish power.
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


  /*
   * Set up for a transaction.
   *
   * First, reset the module.  This will blow away pending interrupts and
   * interrupt enables.  Will this also make it impossible for the bus
   * to be busy?
   *
   * Reset and then make sure the bus isn't busy.
   */

  error_t start_check_busy() {
    uint16_t t0, t1;

    call Usci.enterResetMode_();			// blow any cruft away
    call Usci.leaveResetMode_();

    t0 = call Platform.usecsRaw();
    while (call Usci.isBusBusy()) {
      t1 = call Platform.usecsRaw();
      if (t1 - t0 > I2C_MAX_TIME) {
	__PANIC_I2C(6, t1, t0, 0);
	return EBUSY;
      }
    }
    return SUCCESS;
  }


  /*
   * Wait for a CTRL1 signal to deassert.   These in particular
   * are UCTXNACK, UCTXSTP, and UCTXSTT.
   */
  error_t wait_deassert_ctl1(uint8_t code) {
    uint16_t t0, t1;

    t0 = call Platform.usecsRaw();

    /* wait for code bits to go away */
    while (call Usci.getCtl1() & code) {
      t1 = call Platform.usecsRaw();
      if (t1 - t0 > I2C_MAX_TIME) {
	__PANIC_I2C(7, t1, t0, 0);
	return ETIMEOUT;
      }
    }
    return SUCCESS;
  }


#ifdef notdef
  void send_stop() {				// close out current bus transaction...
    error_t rtn;

    TELL = 1;
    call Usci.setTxStop();			// finish cleaning up
    if ((rtn = wait_deassert_ctl1(UCTXSTP)))
      return;
    TELL = 0;
  }
#endif


  error_t wait_ifg(uint8_t code) {
    uint16_t t0, t1;
    uint8_t ifg;

    t0 = call Platform.usecsRaw();
    while (1) {
      ifg = call Usci.getIfg();
      if (ifg & UCNACKIFG) {				// didn't respond.
	__PANIC_I2C(9, ifg, 0, 0);
	return EINVAL;
      }
      if (ifg & code) break;
      t1 = call Platform.usecsRaw();
      if (t1 - t0 > I2C_MAX_TIME) {
	__PANIC_I2C(10, t1, t0, 0);
	return ETIMEOUT;
      }
    }
    return SUCCESS;
  }


  /*************************************************************************/

  async command error_t I2CBasicAddr.read[uint8_t client]( i2c_flags_t flags,
					   uint16_t addr, uint8_t len, 
					   uint8_t* buf ) {

    /*
     * According to TI, we can just poll until the start condition
     * clears.  But we're nervous and want to bail out if it doesn't
     * clear fast enough.  This is how many times we loop before we
     * bail out.
     */

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
      if (call Usci.isBusBusy()) {	/* shouldn't be busy */
	__PANIC_I2C(2, call Usci.getStat(), 0, 0);
	return EBUSY;
      }

      call Usci.setReceiveMode();	/* clears CTR, reading */
      call Usci.setTxStart();		/* set TXSTT, send Start  */

      // enable nack and rx interrupts only
      call Usci.setIe(UCNACKIE | UCRXIE);

      /*
       * if only reading 1 byte, STOP bit must be set right after
       * START condition is triggered
       */
      if ( (m_len == 1) && (m_flags & I2C_STOP) ) {
        //this logic seems to work fine
        /* wait until START bit has been transmitted */
        while (call Usci.getTxStart()) {
	  if (!(--counter)) {
	    __PANIC_I2C(3, 0, 0, 0);
	  }
        }
	call Usci.setTxStop();
      }
    } else if (m_flags & I2C_RESTART) {
      call Usci.setI2Csa(addr);

      /*
       * clear TR (receive), generate START
       */
      call Usci.setReceiveMode();	/* clears CTR, reading */
      call Usci.setTxStart();		/* set TXSTT, send Start  */

      // enable nack and rx only
      call Usci.setIe(UCNACKIE | UCRXIE);

      /* if only reading 1 byte, STOP bit must be set right after START bit */
      if ( (m_len == 1) && (m_flags & I2C_STOP) ) {
        /* wait until START bit has been transmitted */
        while (call Usci.getCtl1() & UCTXSTT) {
	  if ((--counter) == 0) {	/* went to zero */
	    __PANIC_I2C(4, 0, 0, 0);
	  }
        }
	call Usci.setTxStop();
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
      call Usci.setTxStop();
    }
    /* read byte from RX buffer */
    m_buf[ m_pos++ ] = call Usci.getRxbuf();

    //TODO: this should check m_flags: if RESTART flag is present, we
    //should not send stop condition
    if (m_pos == m_len) {

      //when we receive the last byte, wait until STP condition is
      //cleared, then return.
      while (call Usci.getTxStop() && (counter > 1))
        counter --;

      //disable the rx interrupt
      call Usci.disableRxIntr();
      signal I2CBasicAddr.readDone[call ArbiterInfo.userId()](
	(counter > 1) ? SUCCESS : FAIL,
	call Usci.getI2Csa(), m_pos, m_buf);
    }
  }
  
  async command error_t I2CBasicAddr.write[uint8_t client](i2c_flags_t flags,
					    uint16_t addr, uint8_t len,
					    uint8_t* buf) {
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
      if (call Usci.isBusBusy()) {	/* shouldn't be busy */
	__PANIC_I2C(5, call Usci.getStat(), 0, 0);
	return EBUSY;
      }

      call Usci.orCtl1(UCTR | UCTXSTT);		// writing, Start.

      /*
       * enable relevant state interrupts and TX, clear the rest
       */

//    while (call Usci.getTxStart()) { }

      call Usci.setIe(UCNACKIE | UCTXIE);

    } else if (m_flags & I2C_RESTART) {
      /* is this a restart or a direct continuation */
      call Usci.setI2Csa(addr);

      call Usci.orCtl1(UCTR | UCTXSTT);		// writing, Start.

      //do we not need to enable any interrupts here?

    } else
      nextWrite();
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

    if (call Usci.getTxStart())
      m_pos = 0;

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
      call Usci.setTxStop();

      /* wait until STOP bit has been transmitted */
      while (call Usci.getTxStop() && (counter > 1))
	counter--;
    }

    call Usci.disableTxIntr();		// we are done, no more txintrs
    signal I2CBasicAddr.writeDone[call ArbiterInfo.userId()](
	(counter > 1) ? SUCCESS : FAIL,
	call Usci.getI2Csa(), m_len, m_buf);
    return;
  }


  // defaults

  default async event void I2CBasicAddr.readDone[uint8_t client](error_t error, uint16_t addr,
								 uint8_t length, uint8_t* data)  {}

  default async event void I2CBasicAddr.writeDone[uint8_t client](error_t error, uint16_t addr,
								  uint8_t length, uint8_t* data) {}

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

    /* Nobody home, abort.   Read or Write */
    call Usci.setTxStop();

    /* wait until STOP bit has been transmitted */
    while (call Usci.getTxStop() && (counter > 1)) {
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
    if (call Usci.getTransmitReceiveMode()) { /* 1 if transmitting, UCTR */
      signal I2CBasicAddr.writeDone[call ArbiterInfo.userId()]( ENOACK, call Usci.getI2Csa(), m_len, m_buf );
    } else {
      signal I2CBasicAddr.readDone[call ArbiterInfo.userId()]( ENOACK, call Usci.getI2Csa(), m_len, m_buf );
    }
  }


  /***************************************************************************/


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


  /***************************************************************************/


  /*
   * see if the slave is out there...
   *
   * 0  if no one home
   * 1  well your guess here.
   */
  async command bool I2CReg.slave_present[uint8_t client](uint16_t sa) {
    error_t rtn;

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;
    if ((rtn = start_check_busy()))
      return rtn;

    call Usci.setI2Csa(sa);
    call Usci.orCtl1(UCTR | UCTXSTT | UCTXSTP);		// Write, Start, Stop

    if ((rtn = wait_deassert_ctl1(UCTXSTP)))
      return rtn;

    rtn = call Usci.isNackIntrPending();		// 1 says NACK'd
    return (!rtn);					// we want the opposite sense
  }


  /*
   * reg_read:
   *
   * START (w/ device addr, in i2csa), transmit
   * 1st write the reg addr
   * 2nd restart (w/device addr), receive
   * read byte (reg contents)
   * finish
   */
  async command error_t I2CReg.reg_read[uint8_t client_id](uint16_t sa, uint8_t reg, uint8_t *val) {
    uint16_t data;
    error_t rtn;

    *val = 0;
    if ((rtn = start_check_busy()))
      return rtn;
    call Usci.setI2Csa(sa);

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;

    /* We want to write the regAddr, send the SA and then write regAddr */
    call Usci.orCtl1(UCTR | UCTXSTT);		// TR (write) & STT

    /*
     * get 1st TxIFG
     *
     * The MSP430 is double buffered.  1st TxIFG will show up shortly after
     * TxSTT has been sent (both buffers empty).   We write the first byte
     * (the reg addr), it gets moved to the output buffer (shift register) and
     * will start to be clocked out.   2nd TxIFG will show at this point.
     * This is when we want to turn the bus around so we can receive the
     * byte coming back.
     */

    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;
    call Usci.setTxbuf(reg);			// write register address

    /* looking for 2nd TxIFG */
    if ((rtn = wait_ifg(UCTXIFG)))		// says 1st byte got ack'd
      return rtn;

    /*
     * receive one byte
     *
     * First turn the bus around with a Restart.  Wait for the TxStart
     * to take and then assert the Stop.   This should put the stop
     * on the first receive byte.
     */
    call Usci.setReceiveMode();			// clears CTR
    call Usci.setTxStart();

    /* wait for the TxStart to go away */
    if ((rtn = wait_deassert_ctl1(UCTXSTT)))
      return rtn;
    call Usci.setTxStop();

    /* wait for inbound char to show up, first rx byte */
    if ((rtn = wait_ifg(UCRXIFG)))
      return rtn;

    data = call Usci.getRxbuf();
    *val = data;
    nop();
    return SUCCESS;
  }


  /*
   * reg_read16
   *
   * address slave (sa)
   * tx (write) reg addr (reg) to the device
   * restart (assert TXStart) to turn bus around
   * read two bytes.
   */
  async command error_t I2CReg.reg_read16[uint8_t client_id](uint16_t sa, uint8_t reg, uint16_t *val) {
    uint16_t data;
    error_t rtn;

    *val = 0;
    if ((rtn = start_check_busy()))
      return rtn;
    call Usci.setI2Csa(sa);

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;

    /* We want to write the regAddr, send the SA and then write regAddr */
    call Usci.orCtl1(UCTR | UCTXSTT);		// TR (write) & STT

    /*
     * get 1st TxIFG
     *
     * The MSP430 is double buffered.  1st TxIFG will show up shortly after
     * TxSTT has been sent (both buffers empty).   We write the first byte
     * (the reg addr), it gets moved to the output buffer (shift register) and
     * will start to be clocked out.   2nd TxIFG will show at this point.
     * This is when we want to turn the bus around so we can receive two
     * bytes.  (Send a Restart (assert TxSTT again, but this time indicate
     * receiving)).   This will occur after the current outgoing byte (in
     * the outbound serial register) has been ACK'd.
     */

    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;
    call Usci.setTxbuf(reg);			// write register address

    /* looking for 2nd TxIFG */
    if ((rtn = wait_ifg(UCTXIFG)))		// says 1st byte got ack'd
      return rtn;

    /*
     * receive two bytes
     *
     * First turn the bus around with a Restart.
     *
     * Also double buffered....    When the 1st RxIFG asserts saying
     * there is something in RxBUF, the 2nd byte is also being clocked
     * into the Rx Shift register.  (unless the slave isn't ready in which
     * case it will be doing clock stretching, SCLLOW will be asserted).
     *
     * So if we want to receive two bytes all is good.   TxStop needs
     * to be asserted while the 2nd byte is being received which
     * means after the 1st RxIFG has been seen.   We should get one
     * more RxIFG and that should complete the transaction.
     */
    call Usci.setReceiveMode();			// clears CTR
    call Usci.setTxStart();

    /* wait for the TxStart to go away */
    if ((rtn = wait_deassert_ctl1(UCTXSTT)))
      return rtn;

    /* wait for inbound char to show up, first rx byte */
    if ((rtn = wait_ifg(UCRXIFG)))
      return rtn;

    /*
     * Since we have RxIntr asserted, we have a byte in the RxBuf and its been ack'd.
     * The next byte is in progress so set TxStop.  It will go on the next byte.
     * Then actually read the current byte which will unfreeze the state machine.
     *
     * This will avoid starting another bus cycle, which can happen if we set
     * stop after reading the first byte.   Depends on if the bus is stalled.
     * Ie. we got backed up and the I2C h/w is ahead of us.
     */
    call Usci.setTxStop();

    data = call Usci.getRxbuf();
    data = data << 8;
    if ((rtn = wait_ifg(UCRXIFG)))
      return rtn;
    data |= call Usci.getRxbuf();
    *val = data;
    nop();
    return SUCCESS;
  }


  async command error_t I2CReg.reg_readBlock[uint8_t client_id](uint16_t sa,
				uint8_t reg, uint8_t num_bytes, uint8_t *buf) {
    uint16_t left;
    error_t  rtn;

    if (num_bytes == 0 || buf == NULL)
      return EINVAL;

    left = num_bytes;

    /*
     * special case of left starts out 1, single byte.
     *
     */
    if (left == 1)
      return call I2CReg.reg_read[client_id](sa, reg, &buf[0]);

    if ((rtn = start_check_busy()))
      return rtn;
    call Usci.setI2Csa(sa);

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;

    /* We want to write the regAddr, send the SA and then write regAddr */
    call Usci.orCtl1(UCTR | UCTXSTT);		// TR (write) & STT

    /*
     * get 1st TxIFG
     *
     * The MSP430 is double buffered.  1st TxIFG will show up shortly after
     * TxSTT has been sent (both buffers empty).   We write the first byte
     * (the reg addr), it gets moved to the output buffer (shift register) and
     * will start to be clocked out.   2nd TxIFG will show at this point.
     * This is when we want to turn the bus around so we can start to receive
     * bytes.  (Send a Restart (assert TxSTT again, but this time indicate
     * receiving)).   This will occur after the current outgoing byte (in
     * the outbound serial register) has been ACK'd.
     */

    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;
    call Usci.setTxbuf(reg);			// write register address

    /* looking for 2nd TxIFG */
    if ((rtn = wait_ifg(UCTXIFG)))		// says 1st byte got ack'd
      return rtn;

    /*
     * Turn the bus around with a Restart.
     */
    call Usci.setReceiveMode();			// clears CTR
    call Usci.setTxStart();

    /* wait for the TxStart to go away */
    if ((rtn = wait_deassert_ctl1(UCTXSTT)))
      return rtn;

    /*
     * RX is doubled buffered.   There is the incoming shift register (SR)
     * which feeds the actual RXBUF.  When rxbuf is loaded rxifg is asserted.
     *
     * After rxbuf is loaded, the next byte will start to be clocked into
     * SR.  If rxbuf hasn't been emptied by the time 7 bit times have gone
     * by, the state machine will stop clocking (scl will be low) until
     * rxbuf gets emptied.
     *
     * What happens if we assert TxStop when we are holding off the receiver?
     */
    while (left) {
      if ((rtn = wait_ifg(UCRXIFG)))
	return rtn;
      left--;

      /*
       * If there is only one more byte left, then set stop.
       * The state machine will have already started to receive
       * into the SR so the last byte is on the fly.
       *
       * If the state machine hung (on bit 7, scl low), setting
       * TxStop prior to pulling the last byte will issue the
       * Stop after this last byte.
       *
       * The order of setting txStop and pulling the Rxbuf byte
       * is important.
       */
      if (left == 1)
	call Usci.setTxStop();
      *buf++ = call Usci.getRxbuf();
    }
    if ((rtn = wait_deassert_ctl1(UCTXSTP)))
      return rtn;
    nop();
    return SUCCESS;
  }


  /*
   * reg_write:
   *
   * START (w/ device addr, in i2csa), transmit
   * 1st write the reg addr
   * write byte (reg contents)
   * finish
   */
  async command error_t I2CReg.reg_write[uint8_t client_id](uint16_t sa,
						    uint8_t reg, uint8_t val) {
    error_t rtn;

    if ((rtn = start_check_busy()))
      return rtn;
    call Usci.setI2Csa(sa);

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;

    /* We want to write the regAddr, send the SA and then write regAddr */
    call Usci.orCtl1(UCTR | UCTXSTT);		// TR (write) & STT

    /*
     * get 1st TxIFG
     *
     * The MSP430 is double buffered.  1st TxIFG will show up shortly after
     * TxSTT has been sent (both buffers empty).   We write the first byte
     * (the reg addr), it gets moved to the output buffer (shift register) and
     * will start to be clocked out.   2nd TxIFG will show at this point.
     * This is when we want to turn the bus around so we can receive the
     * byte coming back.
     */

    if ((rtn = wait_ifg(UCTXIFG)))		// wait for txstart to finish
      return rtn;

    call Usci.setTxbuf(reg);			// write register address
    if ((rtn = wait_ifg(UCTXIFG)))		// says reg addr got ack'd
      return rtn;

    /*
     * write one byte
     *
     * We've got an existing TxIFG, so we have room.  Write the new value
     * and wait until it gets moved into the shift register (TxIfg will come
     * up when this happens).  Then set TxStop to finish.
     */
    call Usci.setTxbuf(val);
    if ((rtn = wait_ifg(UCTXIFG)))		// says val got ack'd
      return rtn;

    call Usci.setTxStop();
    if ((rtn = wait_deassert_ctl1(UCTXSTP)))
      return rtn;

    nop();
    return SUCCESS;
  }


  async command error_t I2CReg.reg_write16[uint8_t client_id](uint16_t sa,
						      uint8_t reg, uint16_t val) {
    error_t rtn;

    if ((rtn = start_check_busy()))
      return rtn;
    call Usci.setI2Csa(sa);

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;

    /* We want to write the regAddr, send the SA and then write regAddr */
    call Usci.orCtl1(UCTR | UCTXSTT);		// TR (write) & STT

    /*
     * get 1st TxIFG
     *
     * The MSP430 is double buffered.  1st TxIFG will show up shortly after
     * TxSTT has been sent (both buffers empty).   We write the first byte
     * (the reg addr), it gets moved to the output buffer (shift register) and
     * will start to be clocked out.   2nd TxIFG will show at this point.
     * This is when we want to turn the bus around so we can receive the
     * byte coming back.
     */

    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;
    call Usci.setTxbuf(reg);			// write register address

    /* looking for 2nd TxIFG */
    if ((rtn = wait_ifg(UCTXIFG)))		// says reg addr got ack'd
      return rtn;

    /*
     * write first byte, we do msb first.
     * We've got an existing TxIFG, so we have room.
     */
    call Usci.setTxbuf(val >> 8);		// msb part
    if ((rtn = wait_ifg(UCTXIFG)))		// says 1st byte got ack'd
      return rtn;

    /*
     * send 2nd, but wait until it is in the shift register
     * before sending Stop
     */
    call Usci.setTxbuf(val & 0xff);		// lsb part
    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;

    call Usci.setTxStop();
    if ((rtn = wait_deassert_ctl1(UCTXSTP)))
      return rtn;

    nop();
    return SUCCESS;
  }


  async command error_t I2CReg.reg_writeBlock[uint8_t client_id](uint16_t sa,
				uint8_t reg, uint8_t num_bytes, uint8_t *buf) {
    uint16_t left;
    error_t  rtn;

    if (num_bytes == 0 || buf == NULL)
      return EINVAL;

    left = num_bytes;

    if ((rtn = start_check_busy()))
      return rtn;
    call Usci.setI2Csa(sa);

    nop();
    TOGGLE_TELL;
    TOGGLE_TELL;

    /* We want to write the regAddr, send the SA and then write regAddr */
    call Usci.orCtl1(UCTR | UCTXSTT);		// TR (write) & STT

    /*
     * get 1st TxIFG
     *
     * The MSP430 is double buffered.  1st TxIFG will show up shortly after
     * TxSTT has been sent (both buffers empty).   We write the first byte
     * (the reg addr), it gets moved to the output buffer (shift register) and
     * will start to be clocked out.   2nd TxIFG will show at this point.
     * This is when we want to turn the bus around so we can start to receive
     * bytes.  (Send a Restart (assert TxSTT again, but this time indicate
     * receiving)).   This will occur after the current outgoing byte (in
     * the outbound serial register) has been ACK'd.
     */

    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;
    call Usci.setTxbuf(reg);			// write register address

    while (left) {
      if ((rtn = wait_ifg(UCTXIFG)))		// says 1st byte got ack'd
	return rtn;

      left--;
      call Usci.setTxbuf(*buf++);
    }
    /*
     * we have to wait until the last byte written actually
     * makes it into the SR before setting Stop.
     */
    if ((rtn = wait_ifg(UCTXIFG)))
      return rtn;
    call Usci.setTxStop();
    if ((rtn = wait_deassert_ctl1(UCTXSTP)))
      return rtn;
    nop();
    return SUCCESS;
  }


#ifndef REQUIRE_PLATFORM
  default async command uint16_t Platform.usecsRaw()    { return 0; }
  default async command uint16_t Platform.jiffiesRaw() { return 0; }
#endif

#ifndef REQUIRE_PANIC
  default async command void Panic.panic(uint8_t pcode, uint8_t where, uint16_t arg0,
					 uint16_t arg1, uint16_t arg2, uint16_t arg3) { }
  default async command void  Panic.warn(uint8_t pcode, uint8_t where, uint16_t arg0,
					 uint16_t arg1, uint16_t arg2, uint16_t arg3) { }
#endif
}
