#include <stdio.h>

/**
 * Manual test for UartStream receive functions.
 *
 * Use a terminal emulator program connected to the serial port.
 * Enter single characters, followed by a block of characters,
 * followed by more single characters, per the instructions printed to
 * the serial port. */
module TestP @safe()
{
  uses {
    interface Timer<TMilli> as Periodic;
    interface Boot;
    interface Leds;
    interface UartStream;
    interface UartByte;
  }
}
implementation
{
  enum { RX_SINGLE_NEED = 5 };

  norace int8_t rx_single_need;
  norace int8_t rx_multi_need;
  uint8_t rx_buffer[5];
  
  norace volatile bool busy;

  task void printStatus ()
  {
  }

  event void Periodic.fired ()
  {
    /* Yes, I know this isn't atomic.  Close enough for a test. */
    while (busy) {
      ;
    }
    busy = TRUE;
    printf("Awaiting %d block chars and %d single chars\r\n", rx_multi_need, rx_single_need);
    busy = FALSE;
  }

  event void Boot.booted()  {
    error_t rv;

    rv = call UartStream.enableReceiveInterrupt();
    printf("# RX enable got %d\r\n", rv);
    if (SUCCESS == rv) {
      rx_multi_need = sizeof(rx_buffer)-1;
      rx_single_need = RX_SINGLE_NEED;
      printf("# RX expect %d single, %d block, %d single before disable\r\n", rx_single_need, rx_multi_need, rx_single_need);
      printf("# LED2 should toggle for single character receptions\r\n"); 
    }
    call Periodic.startPeriodic(10000);
  }

  async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t err) { }

  async event void UartStream.receivedByte (uint8_t byte)
  {
    while (busy) {
      ;
    }
    busy = TRUE;
    printf("Received single char 0x%02x\r\n", byte);
    call Leds.led2Toggle();
    if (0 == --rx_single_need) {
      error_t rv;
      if (0 < rx_multi_need) {
        rv = call UartStream.receive(rx_buffer, rx_multi_need);
        printf("Completed first single set; block receive request returned %d\r\n", rv);
        printf("(LED2 should not toggle during block receive)\r\n"); 
      } else {
        rv = call UartStream.disableReceiveInterrupt();
        printf("Completed second single set; block disable interrupt returned %d\r\n", rv);
        printf("(LED2 should stop toggling)\r\n"); 
      }
    }
    busy = FALSE;
  }

  async event void UartStream.receiveDone (uint8_t* buf, uint16_t len, error_t err)
  {
    while (busy) {
      ;
    }
    busy = TRUE;
    rx_multi_need = 0;
    rx_single_need = RX_SINGLE_NEED;
    rx_buffer[sizeof(rx_buffer)-1] = 0;
    printf("Stream read completed: '%s'\r\n", rx_buffer);
    printf("Continuing with %d single chars\r\n", rx_single_need);
    printf("(LED2 should toggle for each single character)\r\n"); 
    busy = FALSE;
  }
}

