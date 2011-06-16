#include <stdio.h>

module TestP @safe()
{
  uses {
    interface Boot;
    interface Leds;
    interface Resource as Resource1;
    interface UartByte as UartByte1;
    interface Resource as Resource2;
    interface UartByte as UartByte2;
  }

}
implementation
{

  void fail () {
    call Leds.led1On();
    while (1);
  }

#define ASSERT(_expr) if (! (_expr)) { fail(); }
#define ASSERT_EQUAL(_expr, _value) if ((_value) != (_expr)) { fail(); }

  void dumpHex (unsigned int v) {
    int i;
    for (i = 12; 0 <= i; i -= 4) {
      uint8_t n = (v >> i) & 0x0f;
      while (! (UCTXIFG & UCA0IFG));
      UCA0TXBUF = (0x0a <= n) ? ('a' + n - 10) : '0' + n;
    }
    while (! (UCTXIFG & UCA0IFG));
  }


  void dumpText (const char* p) {
    while (*p) {
      call Leds.led1On();
      while (! (UCTXIFG & UCA0IFG)) {
      }
      call Leds.led1Off();
      UCA0TXBUF = *p++;
    }
    while (! (UCTXIFG & UCA0IFG)) {
    }
  }

  void dumpTextUart1 (const char* cp) {
    while (*cp) {
      ASSERT_EQUAL(SUCCESS, call UartByte1.send(*cp++));
    }
  }

  void dumpTextUart2 (const char* cp) {
    while (*cp) {
      ASSERT_EQUAL(SUCCESS, call UartByte2.send(*cp++));
    }
  }

  event void Boot.booted()  {
#if 1

    ASSERT_EQUAL(EOFF, call UartByte1.send('1'));
    ASSERT_EQUAL(SUCCESS,  call Resource1.immediateRequest());
    ASSERT_EQUAL(SUCCESS, call UartByte1.send('1'));             // 1
    dumpTextUart1("\r\nPast first test\r\n");
    ASSERT_EQUAL(EBUSY, call UartByte2.send('2'));
#if ! defined(MSP430XV2_USCI_UART_IDLE_RELEASE_FEATURE)
    /* Following only succeeds if idle resource is not released on request */
    ASSERT_EQUAL(FAIL,  call Resource2.immediateRequest());
    ASSERT_EQUAL(SUCCESS, call Resource1.release());
    ASSERT_EQUAL(EOFF, call UartByte1.send('1'));
#endif
    ASSERT_EQUAL(SUCCESS,  call Resource2.immediateRequest());
    ASSERT_EQUAL(SUCCESS, call UartByte2.send('2'));             // 2
    /* The following message may be garbled if the receiver has lost sync */
    dumpTextUart2("\r\nSwitched to second client\r\n");
#else
    uint8_t stat;
    volatile uint16_t ctr = 0;
    
    ASSERT_EQUAL(EOFF, call UartByte1.send('1'));
    ASSERT_EQUAL(SUCCESS,  call Resource1.immediateRequest());
    dumpText("\r\nStarting\r\n");
    dumpHex(UCA0STAT);
    dumpText("Line2\r\n");
    dumpText("Line3\r\n");
    ASSERT_EQUAL(SUCCESS, call UartByte1.send('1'));
    ASSERT_EQUAL(FAIL,  call Resource1.immediateRequest());
    ASSERT_EQUAL(EBUSY, call UartByte2.send('2'));
    ASSERT_EQUAL(FAIL,  call Resource2.immediateRequest());
    dumpText("Releasing\r\n");
    ASSERT_EQUAL(SUCCESS, call Resource1.release());
    stat = UCA0STAT;
    ASSERT_EQUAL(EOFF, call UartByte1.send('1'));
    ASSERT_EQUAL(SUCCESS,  call Resource1.immediateRequest());
    ctr = 0;
    while (++ctr);
    dumpText("Reclaimed; releasing again\r\n");
    ASSERT_EQUAL(SUCCESS, call Resource1.release());

    ASSERT_EQUAL(SUCCESS,  call Resource2.immediateRequest());
    dumpText("\r\nClient 2 started\r\n");
    ctr = 0;
    while (++ctr);
    ASSERT_EQUAL(SUCCESS, call UartByte2.send('2'));
    dumpText("Reached end\r\n");
    dumpHex(stat);
    dumpText(" was stat\r\n");
#endif
    call Leds.led0On();
  }

  event void Resource1.granted () { }
  event void Resource2.granted () { }
}
