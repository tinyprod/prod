#include <stdio.h>

module TestP @safe()
{
  uses {
    interface Boot;
    interface Leds;
    interface UartStream;
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

  uint8_t message[] = "This is my long message\r\n";
  uint16_t message_len = sizeof(message) - 1; // Subtract EOS

  int iterations = 1000;

  task void transmitMessage ()
  {
    ASSERT_EQUAL(SUCCESS, call UartStream.send(message, message_len))
  }

  event void Boot.booted()  {
    printf("Preparing to send message of %d bytes\r\n", message_len);
    post transmitMessage();
  }

  async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t err)
  {
    if (0 < --iterations) {
      post transmitMessage();
    } else {
      printf("Sent %d chars from %p completed with %d\r\n", len, buf, err);
      call Leds.led0On();
    }
  }

  async event void UartStream.receivedByte (uint8_t byte) { }
  async event void UartStream.receiveDone (uint8_t* buf, uint16_t len, error_t err) { }
}

