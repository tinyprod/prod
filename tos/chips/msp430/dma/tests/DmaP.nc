/**
 *  @author Eric B. Decker
 *  @date   Apr 14, 2011
 **/

#include <Msp430Dma.h>

typedef enum {
  DS_STAGE_ONE = 1,
  DS_CHECK,
} dma_state_t;

volatile uint16_t start = 0;
norace dma_state_t m_dma_state;


#define BUFSIZE_BYTES 512
#define BUFSIZE_WORDS (BUFSIZE_BYTES/2)

typedef struct {
  uint16_t maj_a;
  uint8_t buf[BUFSIZE_BYTES];
  uint16_t maj_b;
} buf_t;

buf_t B0;
buf_t B1;
buf_t B2;
buf_t B3;

#define B0_MAJ 0xefef
#define B1_MAJ 0x0101
#define B2_MAJ 0x2020
#define B3_MAJ 0x3333

module DmaP {
  uses {
    interface Boot;
    interface Msp430DmaControl as Dma;
    interface Msp430DmaChannel as Dma0;
    interface Msp430DmaChannel as Dma1;
    interface Msp430DmaChannel as Dma2;
  }
}
implementation {

  task void dmatask() {
    switch (m_dma_state) {
      case DS_STAGE_ONE:
	call Dma.reset();
	call Dma0.setupTransfer(
		  DMA_DT_BURST_BLOCK |		// interleaved, block, edge sensitive
		  DMA_SW_DW |			// SRC word, DST word
		  DMA_SRC_INC | 		// SRC address, increment
		  DMA_DST_INC |			// DST address, increment
		  DMAEN | DMAIE,
		DMA_TRIGGER_DMAREQ,
		(uint16_t) B0.buf,
		(uint16_t) B1.buf,
		BUFSIZE_WORDS);
	call Dma1.setupTransfer(
		  DMA_DT_BURST_BLOCK |		// interleaved, block, edge sensitive
		  DMA_SW_DW |			// SRC word, DST word
		  DMA_SRC_INC | 		// SRC address, increment
		  DMA_DST_INC |			// DST address, increment
		  DMAEN | DMAIE,
		DMA_TRIGGER_DMAxIFG,
		(uint16_t) B1.buf,
		(uint16_t) B2.buf,
		BUFSIZE_WORDS);
	call Dma2.setupTransfer(
		  DMA_DT_BURST_BLOCK |		// interleaved, block, edge sensitive
		  DMA_SW_DW |			// SRC word, DST word
		  DMA_SRC_INC | 		// SRC address, increment
		  DMA_DST_INC |			// DST address, increment
		  DMAEN | DMAIE,
		DMA_TRIGGER_DMAxIFG,
		(uint16_t) B2.buf,
		(uint16_t) B3.buf,
		BUFSIZE_WORDS);
	nop();
	call Dma0.softwareTrigger();
	break;
      case DS_CHECK:
	nop();
	break;
    }
  }

  event void Boot.booted() {
    int i;
    uint32_t addr;

    while (!start)
      nop();

    atomic {
      DMACTL0 = 0x4321;
      DMACTL1 = 0x432f;

      addr = 0xfefefe;
      DMA0CTL = 0xffe0;
#ifdef __MSP430_HAS_DMAX_3__
      __asm__ __volatile__ ("movx.a %1,%0":"=m" (DMA0SA):"m" (addr));
      __asm__ __volatile__ ("movx.a %1,%0":"=m" (DMA0DA):"m" (addr));
      DMA0SZ  = 0xfffe;
      DMA1CTL = 0xffe0;
      __asm__ __volatile__ ("movx.a %1,%0":"=m" (DMA1SA):"m" (addr));
      __asm__ __volatile__ ("movx.a %1,%0":"=m" (DMA1DA):"m" (addr));
      DMA1SZ  = 0xfffe;
      DMA2CTL = 0xffe0;
      __asm__ __volatile__ ("movx.a %1,%0":"=m" (DMA2SA):"m" (addr));
      __asm__ __volatile__ ("movx.a %1,%0":"=m" (DMA2DA):"m" (addr));
      DMA2SZ  = 0xfffe;
#else
      DMA0SA = addr;
      DMA0DA = addr;
      DMA0SZ  = 0xfffe;
      DMA1CTL = 0xffe0;
      DMA1SA = addr;
      DMA1DA = addr;
      DMA1SZ  = 0xfffe;
      DMA2CTL = 0xffe0;
      DMA2SA = addr;
      DMA2DA = addr;
      DMA2SZ  = 0xfffe;
#endif
    }

    B0.maj_a = B0_MAJ;
    B0.maj_b = B0_MAJ;
    B1.maj_a = B1_MAJ;
    B1.maj_b = B1_MAJ;
    B2.maj_a = B2_MAJ;
    B2.maj_b = B2_MAJ;
    B3.maj_a = B3_MAJ;
    B3.maj_b = B3_MAJ;
    for (i = 0; i < BUFSIZE_BYTES; i++)
      B0.buf[i] = i;
    m_dma_state = DS_STAGE_ONE;
    post dmatask();
  }

  async event void Dma0.transferDone() {
    nop();
  }
  async event void Dma1.transferDone() {
    nop();
  }
  async event void Dma2.transferDone() {
    m_dma_state = DS_CHECK;
    post dmatask();
  }
}
