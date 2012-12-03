/*
 * Copyright (c) 2010 People Power Co.
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
 * Radio interface implementation for any RF1A module present.
 *
 * This module makes available the module-specific interface registers and
 * implements the interface to the module core registers.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 */

/*
 * TI really has an arm where a leg is needed!    The implementation of
 * an on chip CC1101 core is called the RF1A but for some stupid reason
 * they call the define HAS_CC1101.   Sigh.
 */
#if !defined(__MSP430_HAS_CC1101__)
#error "HplMsp430Rf1aIfP: processor not supported, need CC1101 (RF1A)"
#endif

generic module HplMsp430Rf1aIfP (
  /** Identifier for this RF1A module, unique across chip */
  uint8_t RF1A_ID,
  /** Offset of RF1AxIFCTL0_ register for x=module_instance */
  unsigned int RF1AxIFCTL0_
) @safe() {
  provides {
    interface HplMsp430Rf1aIf;
  }
} implementation {

#define RF1AxIFCTL0  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x00))
#define RF1AxIFCTL1  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x02))
#define RF1AxIFIFG   (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x02))
#define RF1AxIFIE    (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x03))
#define RF1AxIFERR   (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x06))
#define RF1AxIFERRV  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x0C))
#define RF1AxIFIV    (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x0E))
#define RF1AxINSTRW  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x10))
#define RF1AxDINB    (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x10))
#define RF1AxINSTRB  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x11))
#define RF1AxINSTR1W (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x12))
#define RF1AxINSTR1B (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x13))
#define RF1AxINSTR2W (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x14))
#define RF1AxINSTR2B (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x15))
#define RF1AxADINW   (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x16))
#define RF1AxSTATW   (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x20))
#define RF1AxDOUTB   (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x20))
#define RF1AxSTATB   (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x21))
#define RF1AxSTAT1W  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x22))
#define RF1AxDOUT1B  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x22))
#define RF1AxSTAT1B  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x23))
#define RF1AxSTAT2W  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x24))
#define RF1AxDOUT2B  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x24))
#define RF1AxSTAT2B  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x25))
#define RF1AxDOUTW   (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x28))
#define RF1AxDOUT1W  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x2a))
#define RF1AxDOUT2W  (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x2c))
#define RF1AxIN      (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x30))
#define RF1AxIFG     (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x32))
#define RF1AxIES     (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x34))
#define RF1AxIE      (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x36))
#define RF1AxIV      (*TCAST(volatile uint16_t* ONE, RF1AxIFCTL0_ + 0x38))
#define RF1AxRXFIFO  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x3c))
#define RF1AxTXFIFO  (*TCAST(volatile uint8_t* ONE,  RF1AxIFCTL0_ + 0x3e))

  async command uint8_t HplMsp430Rf1aIf.getModuleIdentifier () { atomic return RF1A_ID; }
  async command uint16_t HplMsp430Rf1aIf.getIfctl0 () { atomic return RF1AxIFCTL0; }
  async command void HplMsp430Rf1aIf.setIfctl0 (uint16_t v) { atomic RF1AxIFCTL0 = v; }
  async command uint16_t HplMsp430Rf1aIf.getIfctl1 () { atomic return RF1AxIFCTL1; }
  async command void HplMsp430Rf1aIf.setIfctl1 (uint16_t v) { atomic RF1AxIFCTL1 = v; }
  async command uint8_t HplMsp430Rf1aIf.getIfifg () { atomic return RF1AxIFIFG; }
  async command void HplMsp430Rf1aIf.setIfifg (uint8_t v) { atomic RF1AxIFIFG = v; }
  async command uint8_t HplMsp430Rf1aIf.getIfie () { atomic return RF1AxIFIE; }
  async command void HplMsp430Rf1aIf.setIfie (uint8_t v) { atomic RF1AxIFIE = v; }
  async command uint16_t HplMsp430Rf1aIf.getIferr () { atomic return RF1AxIFERR; }
  async command void HplMsp430Rf1aIf.setIferr (uint16_t v) { atomic RF1AxIFERR = v; }
  async command uint16_t HplMsp430Rf1aIf.getIferrv () { atomic return RF1AxIFERRV; }
  async command void HplMsp430Rf1aIf.setIferrv (uint16_t v) { atomic RF1AxIFERRV = v; }
  async command uint16_t HplMsp430Rf1aIf.getIfiv () { atomic return RF1AxIFIV; }
  async command void HplMsp430Rf1aIf.setIfiv (uint16_t v) { atomic RF1AxIFIV = v; }
  async command uint16_t HplMsp430Rf1aIf.getInstrw () { atomic return RF1AxINSTRW; }
  async command void HplMsp430Rf1aIf.setInstrw (uint16_t v) { atomic RF1AxINSTRW = v; }
  async command uint8_t HplMsp430Rf1aIf.getDinb () { atomic return RF1AxDINB; }
  async command void HplMsp430Rf1aIf.setDinb (uint8_t v) { atomic RF1AxDINB = v; }
  async command uint8_t HplMsp430Rf1aIf.getInstrb () { atomic return RF1AxINSTRB; }
  async command void HplMsp430Rf1aIf.setInstrb (uint8_t v) { atomic RF1AxINSTRB = v; }
  async command uint8_t HplMsp430Rf1aIf.getInstr1b () { atomic return RF1AxINSTR1B; }
  async command void HplMsp430Rf1aIf.setInstr1b (uint8_t v) { atomic RF1AxINSTR1B = v; }
  async command uint8_t HplMsp430Rf1aIf.getInstr2b () { atomic return RF1AxINSTR2B; }
  async command void HplMsp430Rf1aIf.setInstr2b (uint8_t v) { atomic RF1AxINSTR2B = v; }
  async command uint16_t HplMsp430Rf1aIf.getAdinw () { atomic return RF1AxADINW; }
  async command void HplMsp430Rf1aIf.setAdinw (uint16_t v) { atomic RF1AxADINW = v; }
  async command uint16_t HplMsp430Rf1aIf.getStatw () { atomic return RF1AxSTATW; }
  async command void HplMsp430Rf1aIf.setStatw (uint16_t v) { atomic RF1AxSTATW = v; }
  async command uint8_t HplMsp430Rf1aIf.getDoutb () { atomic return RF1AxDOUTB; }
  async command void HplMsp430Rf1aIf.setDoutb (uint8_t v) { atomic RF1AxDOUTB = v; }
  async command uint8_t HplMsp430Rf1aIf.getStatb () { atomic return RF1AxSTATB; }
  async command void HplMsp430Rf1aIf.setStatb (uint8_t v) { atomic RF1AxSTATB = v; }
  async command uint16_t HplMsp430Rf1aIf.getStat1w () { atomic return RF1AxSTAT1W; }
  async command void HplMsp430Rf1aIf.setStat1w (uint16_t v) { atomic RF1AxSTAT1W = v; }
  async command uint8_t HplMsp430Rf1aIf.getDout1b () { atomic return RF1AxDOUT1B; }
  async command void HplMsp430Rf1aIf.setDout1b (uint8_t v) { atomic RF1AxDOUT1B = v; }
  async command uint8_t HplMsp430Rf1aIf.getStat1b () { atomic return RF1AxSTAT1B; }
  async command void HplMsp430Rf1aIf.setStat1b (uint8_t v) { atomic RF1AxSTAT1B = v; }
  async command uint16_t HplMsp430Rf1aIf.getStat2w () { atomic return RF1AxSTAT2W; }
  async command void HplMsp430Rf1aIf.setStat2w (uint16_t v) { atomic RF1AxSTAT2W = v; }
  async command uint8_t HplMsp430Rf1aIf.getDout2b () { atomic return RF1AxDOUT2B; }
  async command void HplMsp430Rf1aIf.setDout2b (uint8_t v) { atomic RF1AxDOUT2B = v; }
  async command uint8_t HplMsp430Rf1aIf.getStat2b () { atomic return RF1AxSTAT2B; }
  async command void HplMsp430Rf1aIf.setStat2b (uint8_t v) { atomic RF1AxSTAT2B = v; }
  async command uint16_t HplMsp430Rf1aIf.getDoutw () { atomic return RF1AxDOUTW; }
  async command void HplMsp430Rf1aIf.setDoutw (uint16_t v) { atomic RF1AxDOUTW = v; }
  async command uint16_t HplMsp430Rf1aIf.getDout1w () { atomic return RF1AxDOUT1W; }
  async command void HplMsp430Rf1aIf.setDout1w (uint16_t v) { atomic RF1AxDOUT1W = v; }
  async command uint16_t HplMsp430Rf1aIf.getDout2w () { atomic return RF1AxDOUT2W; }
  async command void HplMsp430Rf1aIf.setDout2w (uint16_t v) { atomic RF1AxDOUT2W = v; }
  async command uint16_t HplMsp430Rf1aIf.getIn () { atomic return RF1AxIN; }
  async command void HplMsp430Rf1aIf.setIn (uint16_t v) { atomic RF1AxIN = v; }
  async command uint16_t HplMsp430Rf1aIf.getIfg () { atomic return RF1AxIFG; }
  async command void HplMsp430Rf1aIf.setIfg (uint16_t v) { atomic RF1AxIFG = v; }
  async command uint16_t HplMsp430Rf1aIf.getIes () { atomic return RF1AxIES; }
  async command void HplMsp430Rf1aIf.setIes (uint16_t v) { atomic RF1AxIES = v; }
  async command uint16_t HplMsp430Rf1aIf.getIe () { atomic return RF1AxIE; }
  async command void HplMsp430Rf1aIf.setIe (uint16_t v) { atomic RF1AxIE = v; }
  async command uint16_t HplMsp430Rf1aIf.getIv () { atomic return RF1AxIV; }
  async command void HplMsp430Rf1aIf.setIv (uint16_t v) { atomic RF1AxIV = v; }
  async command uint8_t HplMsp430Rf1aIf.getRxfifo () { atomic return RF1AxRXFIFO; }
  async command void HplMsp430Rf1aIf.setRxfifo (uint8_t v) { atomic RF1AxRXFIFO = v; }
  async command uint8_t HplMsp430Rf1aIf.getTxfifo () { atomic return RF1AxTXFIFO; }
  async command void HplMsp430Rf1aIf.setTxfifo (uint8_t v) { atomic RF1AxTXFIFO = v; }

  async command uint8_t HplMsp430Rf1aIf.strobe (uint8_t instr) {
    unsigned char rv = 0xFF;
    atomic {
      uint8_t base_instr = instr & ~RF_RXSTAT;
      if ((RF_SRES <= base_instr) && (base_instr <= RF_SNOP)) {
        rv = 0;
        RF1AIFCTL1 &= ~(RFSTATIFG);             // Clear the status read flag
        
        while (! (RF1AIFCTL1 & RFINSTRIFG)) {
          ; // Wait for INSTRIFG
        }
        RF1AINSTRB = instr;                    // Write the strobe command    
        
        // Everything but SRES returns a status byte
        if (RF_SRES != base_instr) {
          while (! (RF1AIFCTL1 & RFSTATIFG)) {
            if (RF1AIFCTL1 & RFERRIFG) {
              (void)RF1AIFERRV;
              rv = 0xff;
              break;
            }
            ; // Wait for the status to be valid
          }
          if (RF1AIFCTL1 & RFSTATIFG) {
            rv = RF1ASTATB;
          }
        }
      }
    }
    return rv;
  }

  async command uint8_t HplMsp430Rf1aIf.readRegister (uint8_t addr) {
    atomic {
      while (! (RF1AIFCTL1 & RFINSTRIFG)) {
        ; // Wait for INSTRIFG
      }
      if ((TEST0 >= addr) || (PATABLE == addr)) {
        RF1AINSTR1B = (RF_SNGLREGRD | addr);
      } else {
        RF1AINSTR1B = (RF_STATREGRD | addr);
      }
      while (! (RF1AIFCTL1 & RFDOUTIFG)) {
        ; // Wait for the data to be valid
      }
      return RF1ADOUTB;
    }
  }

  async command void HplMsp430Rf1aIf.writeRegister (uint8_t addr,
                                                    uint8_t val) {
    atomic {
      while (! (RF1AIFCTL1 & RFINSTRIFG)) {
        ; // Wait for INSTRIFG
      }
      if (TEST0 >= addr) {
        RF1AINSTRB = (RF_REGWR | addr);
      } else {
        RF1AINSTRB = (RF_SNGLREGWR | addr);
      }
      RF1ADINB = val;
      __no_operation();
    }
  }

  async command void HplMsp430Rf1aIf.readBurstRegister (uint8_t addr,
                                                        uint8_t* buf,
                                                        uint8_t len) {
    uint8_t* b1e = buf + len - 1;

    if (0 == len) {
      return;
    }
    atomic {
      while (! (RF1AIFCTL1 & RFINSTRIFG)) {
        ; // Wait for INSTRIFG
      }

      RF1AINSTR1B = (addr | RF_REGRD);
      while (buf < b1e) {
        while (! (RF1AIFCTL1 & RFDOUTIFG)) {
          ; // Wait for the Radio Core to update the RF1ADOUTB reg
        }
        *buf++ = RF1ADOUT1B;
      }
      *buf++ = RF1ADOUT0B;
    }
  }  

  async command void HplMsp430Rf1aIf.writeBurstRegister (uint8_t addr,
                                                         const uint8_t* buf,
                                                         uint8_t len) {
    const uint8_t* be = buf + len;

    if (0 == len) {
      return;
    }
    atomic {
      while (! (RF1AIFCTL1 & RFINSTRIFG)) {
        ; // Wait for INSTRIFG
      }

      // Send address, instruction, and first data byte
      RF1AINSTRW = ((addr | RF_REGWR) << 8) + *buf++;

      while (buf < be) {
        RF1ADINB = *buf++;
        while (! (RF1AIFCTL1 & RFDINIFG)) {
          ; // Wait for write to complete
        }
      }
      (void) RF1ADOUTB;
    }
  }  

  async command uint8_t HplMsp430Rf1aIf.resetRadioCore () {
    uint8_t rv;
    atomic {
      call HplMsp430Rf1aIf.strobe(RF_SRES);
      rv = call HplMsp430Rf1aIf.strobe(RF_SNOP);
    }
    return rv;
  }


#undef RF1AxTXFIFO
#undef RF1AxRXFIFO
#undef RF1AxIV
#undef RF1AxIE
#undef RF1AxIES
#undef RF1AxIFG
#undef RF1AxIN
#undef RF1AxDOUT2W
#undef RF1AxDOUT1W
#undef RF1AxDOUTW
#undef RF1AxSTAT2B
#undef RF1AxDOUT2B
#undef RF1AxSTAT2W
#undef RF1AxSTAT1B
#undef RF1AxDOUT1B
#undef RF1AxSTAT1W
#undef RF1AxSTATB
#undef RF1AxDOUTB
#undef RF1AxSTATW
#undef RF1AxADINW
#undef RF1AxINSTR2B
#undef RF1AxINSTR2W
#undef RF1AxINSTR1B
#undef RF1AxINSTR1W
#undef RF1AxINSTRB
#undef RF1AxDINB
#undef RF1AxINSTRW
#undef RF1AxIFIV
#undef RF1AxIFERRV
#undef RF1AxIFERR
#undef RF1AxIFIE
#undef RF1AxIFIFG
#undef RF1AxIFCTL1
#undef RF1AxIFCTL0
}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
