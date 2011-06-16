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

  uint8_t iteration_limit = 5;

  task void requestClient1 ()
  {
    ASSERT(! call Resource1.isOwner());
    ASSERT_EQUAL(SUCCESS, call Resource1.request());
  }

  task void requestClient2 ()
  {
    ASSERT(! call Resource2.isOwner());
    ASSERT_EQUAL(SUCCESS, call Resource2.request());
  }

  task void acceptClient1 ()
  {
    ASSERT(call Resource1.isOwner());
    dumpTextUart1("\r\nC1" /* "Received control in client 1\r\n" */ );
    ASSERT(! call Resource2.isOwner());
#if ! defined(MSP430XV2_USCI_UART_IDLE_RELEASE_FEATURE)
    dumpTextUart1("\r\nR1r2" /* "Releasing client 1 before requesting client 2\r\n" */);
    call Resource1.release();
#else
    dumpTextUart1("\r\nR2");
#endif /* MSP430XV2_USCI_UART_IDLE_RELEASE_FEATURE */
    post requestClient2();
  }

  task void acceptClient2 ()
  {
    ASSERT(call Resource2.isOwner());
    dumpTextUart2("\r\nC2 ");
    ASSERT(! call Resource1.isOwner());
#if ! defined(MSP430XV2_USCI_UART_IDLE_RELEASE_FEATURE)
    dumpTextUart2("\r\nR2r1");
    call Resource2.release();
#else
    dumpTextUart2("\r\nR1");
#endif /* MSP430XV2_USCI_UART_IDLE_RELEASE_FEATURE */
    if (0 < --iteration_limit) {
      post requestClient1();
    } else {
      dumpText("\r\nCompleted all iterations\r\n");
      call Leds.led0On();
    }
  }

  event void Boot.booted()  {
    ASSERT(! call Resource1.isOwner());
    ASSERT(! call Resource2.isOwner());
    post requestClient1();
  }

  event void Resource1.granted () { post acceptClient1(); }
  event void Resource2.granted () { post acceptClient2(); }
}
