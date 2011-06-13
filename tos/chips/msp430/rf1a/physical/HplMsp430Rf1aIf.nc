/**
 * Copyright (c) 2009-2010 People Power Co.
 * All rights reserved.
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
 */

/**
 * Control of an MSP430 RF1A radio module.
 *
 * A module implementing this interface provides read and write access
 * to all RF1A interface registers, as well as specific higher-level
 * commands such as the ability to read and write RF1A core registers
 * and strobe commands.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

interface HplMsp430Rf1aIf {

  /* ----------------------------------------
   * Introspection to identify a module when given a reference to its
   * component
   */

  /**
   * Return a unique identifier for this module among all RF1A modules on the chip.
    */
  async command uint8_t getModuleIdentifier ();

  /* ----------------------------------------
   * Read and write the module registers.
   */

  /**
   * Reads the RF1AxIFCTL0 interface control register 0.
   */
  async command uint16_t getIfctl0 ();

  /**
   * Writes the RF1AxIFCTL0 interface control register 0.
   */
  async command void setIfctl0 (uint16_t v);

  /**
   * Reads the RF1AxIFCTL1 interface control register 1.
   */
  async command uint16_t getIfctl1 ();

  /**
   * Writes the RF1AxIFCTL1 interface control register 1.
   */
  async command void setIfctl1 (uint16_t v);

  /**
   * Reads the RF1AxIFIFG interface interrupt flag register.
   */
  async command uint8_t getIfifg ();

  /**
   * Writes the RF1AxIFIFG interface interrupt flag register.
   */
  async command void setIfifg (uint8_t v);

  /**
   * Reads the RF1AxIFIE interface interrupt enable register.
   */
  async command uint8_t getIfie ();

  /**
   * Writes the RF1AxIFIE interface interrupt enable register.
   */
  async command void setIfie (uint8_t v);

  /**
   * Reads the RF1AxIFERR interface error flag register.
   */
  async command uint16_t getIferr ();

  /**
   * Writes the RF1AxIFERR interface error flag register.
   */
  async command void setIferr (uint16_t v);

  /**
   * Reads the RF1AxIFERRV interface error vector word register.
   */
  async command uint16_t getIferrv ();

  /**
   * Writes the RF1AxIFERRV interface error vector word register.
   */
  async command void setIferrv (uint16_t v);

  /**
   * Reads the RF1AxIFIV interface interrupt vector word register.
   */
  async command uint16_t getIfiv ();

  /**
   * Writes the RF1AxIFIV interface interrupt vector word register.
   */
  async command void setIfiv (uint16_t v);

  /**
   * Reads the RF1AxINSTRW instruction word register.
   */
  async command uint16_t getInstrw ();

  /**
   * Writes the RF1AxINSTRW instruction word register.
   */
  async command void setInstrw (uint16_t v);

  /**
   * Reads the RF1AxDINB byte data in register.
   */
  async command uint8_t getDinb ();

  /**
   * Writes the RF1AxDINB byte data in register.
   */
  async command void setDinb (uint8_t v);

  /**
   * Reads the RF1AxINSTRB instruction byte register.
   */
  async command uint8_t getInstrb ();

  /**
   * Writes the RF1AxINSTRB instructino byte register.
   */
  async command void setInstrb (uint8_t v);

  /**
   * Reads the RF1AxINSTR1B instruction byte register with 1-byte auto-read.
   */
  async command uint8_t getInstr1b ();

  /**
   * Writes the RF1AxINSTR1B instruction byte register with 1-byte auto-read.
   */
  async command void setInstr1b (uint8_t v);

  /**
   * Reads the RF1AxINSTR2B instruction byte register with 2-byte auto-read.
   */
  async command uint8_t getInstr2b ();

  /**
   * Writes the RF1AxINSTR2B instruction byte register with 2-byte auto-read.
   */
  async command void setInstr2b (uint8_t v);

  /**
   * Reads the RF1AxADINW word data in register.
   */
  async command uint16_t getAdinw ();

  /**
   * Writes the RF1AxADINW word data in register.
   */
  async command void setAdinw (uint16_t v);

  /**
   * Reads the RF1AxSTATW status word register without auto-read.
   */
  async command uint16_t getStatw ();

  /**
   * Writes the RF1AxSTATW status word register without auto-read.
   */
  async command void setStatw (uint16_t v);

  /**
   * Reads the RF1AxDOUTB byte data out register without auto-read.
   */
  async command uint8_t getDoutb ();

  /**
   * Writes the RF1AxDOUTB byte data out register without auto-read.
   */
  async command void setDoutb (uint8_t v);

  /**
   * Reads the RF1AxSTATB status byte register without auto-read.
   */
  async command uint8_t getStatb ();

  /**
   * Writes the RF1AxSTATB status byte register without auto-read.
   */
  async command void setStatb (uint8_t v);

  /**
   * Reads the RF1AxSTAT1W status word register with 1-byte auto-read.
   */
  async command uint16_t getStat1w ();

  /**
   * Writes the RF1AxSTAT1W status word register with 1-byte auto-read.
   */
  async command void setStat1w (uint16_t v);

  /**
   * Reads the RF1AxDOUT1B byte data out register with 1-byte auto-read.
   */
  async command uint8_t getDout1b ();

  /**
   * Writes the RF1AxDOUT1B byte data out register with 1-byte auto-read.
   */
  async command void setDout1b (uint8_t v);

  /**
   * Reads the RF1AxSTAT1B status byte register with 1-byte auto-read.
   */
  async command uint8_t getStat1b ();

  /**
   * Writes the RF1AxSTAT1B status byte register with 1-byte auto-read.
   */
  async command void setStat1b (uint8_t v);

  /**
   * Reads the RF1AxSTAT2W status word register with 2-byte auto-read.
   */
  async command uint16_t getStat2w ();

  /**
   * Writes the RF1AxSTAT2W status word register with 2-byte auto-read.
   */
  async command void setStat2w (uint16_t v);

  /**
   * Reads the RF1AxDOUT2B byte data out register with 2-byte auto-read.
   */
  async command uint8_t getDout2b ();

  /**
   * Writes the RF1AxDOUT2B byte data out register with 2-byte auto-read.
   */
  async command void setDout2b (uint8_t v);

  /**
   * Reads the RF1AxSTAT2B status byte register with 2-byte auto-read.
   */
  async command uint8_t getStat2b ();

  /**
   * Writes the RF1AxSTAT2B status byte register with 2-byte auto-read.
   */
  async command void setStat2b (uint8_t v);

  /**
   * Reads the RF1AxDOUTW data out register without auto-read
   */
  async command uint16_t getDoutw ();

  /**
   * Writes the RF1AxDOUTW data out register without auto-read
   */
  async command void setDoutw (uint16_t v);

  /**
   * Reads the RF1AxDOUT1W data out register with 1-byte auto-read
   */
  async command uint16_t getDout1w ();

  /**
   * Writes the RF1AxDOUT1W data out register with 1-byte auto-read
   */
  async command void setDout1w (uint16_t v);

  /**
   * Reads the RF1AxDOUT2W data out register with 2-byte auto-read
   */
  async command uint16_t getDout2w ();

  /**
   * Writes the RF1AxDOUT2W data out register with 2-byte auto-read
   */
  async command void setDout2w (uint16_t v);

  /**
   * Reads the RF1AxIN core signal input register.
   */
  async command uint16_t getIn ();

  /**
   * Writes the RF1AxIN core signal input register.
   */
  async command void setIn (uint16_t v);

  /**
   * Reads the RF1AxIFG core interrupt flag register.
   */
  async command uint16_t getIfg ();

  /**
   * Writes the RF1AxIFG core interrupt register.
   */
  async command void setIfg (uint16_t v);

  /**
   * Reads the RF1AxIES core interrupt edge select register.
   */
  async command uint16_t getIes ();

  /**
   * Writes the RF1AxIES core interrupt edge select register.
   */
  async command void setIes (uint16_t v);

  /**
   * Reads the RF1AxIE core interrupt enable register.
   */
  async command uint16_t getIe ();

  /**
   * Writes the RF1AxIE core interrupt enable register.
   */
  async command void setIe (uint16_t v);

  /**
   * Reads the RF1AxIV core interrupt vector word register.
   */
  async command uint16_t getIv ();

  /**
   * Writes the RF1AxIV core interrupt vector word register.
   */
  async command void setIv (uint16_t v);

  /**
   * Reads the RF1AxRXFIFO direct receive FIFO access register.
   */
  async command uint8_t getRxfifo ();

  /**
   * Writes the RF1AxRXFIFO direct receive FIFO access register.
   */
  async command void setRxfifo (uint8_t v);

  /**
   * Reads the RF1AxTXFIFO direct transmit FIFO access register.
   */
  async command uint8_t getTxfifo ();

  /**
   * Writes the RF1AxTXFIFO direct transmit FIFO access register.
   */
  async command void setTxfifo (uint8_t v);

  /* ----------------------------------------
   * Higher-level operations.
   */

  /**
   * Send a command strobe.
   *
   * @param instr The instruction value: a valid RF1A command strobe
   * between SRES and SNOP.  The high bit may be set to indicate the
   * source for the returned status.
   *
   * @return If the instruction is invalid, returns 0xFF.  If the
   * instruction is SRES, returns 0.  For all other valid
   * instructions, returns the number of bytes available in the TX
   * (RX) FIFO if the high bit was zero (one).
   */
  async command uint8_t strobe (uint8_t instr);

  /** Read the value from a given register.
   *
   * @param addr A valid RF1A register address
   *
   * @return The contents of the register
   */
  async command uint8_t readRegister (uint8_t addr);

  /** Write a value into a given register.
   *
   * @param addr A valid RF1A configuration register address
   * @param val The value to be written
   */
  async command void writeRegister (uint8_t addr, uint8_t val);

  /** Read multiple values from a register.
   * @param addr A valid RF1A register address
   * @param buf Destination for the data to be read
   * @param len The number of octets to be read
   */
  async command void readBurstRegister (uint8_t addr,
                                        uint8_t* buf,
                                        uint8_t len);

  /** Write multiple values to a register.
   * @param addr A valid RF1A register address
   * @param buf Source for the data to be written
   * @param len The number of octets to be written
   */
  async command void writeBurstRegister (uint8_t addr,
                                         const uint8_t* buf,
                                         uint8_t len);

  /** Reset the radio core.
   *
   * After executing this, all registers will be at their power-up
   * defaults, and the radio will be in sleep mode (NB: this is a
   * difference from the CC1101, which would have put the radio in
   * idle mode).
   * 
   * @return The status byte following the reset.  Expected value is
   * 0x8f.
   */
  async command uint8_t resetRadioCore ();
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
