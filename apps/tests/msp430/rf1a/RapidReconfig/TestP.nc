#include <stdio.h>

module TestP {
  uses {
    interface Boot;
    interface Resource as Rf1aResource;
    interface Alarm<TMilli, uint16_t>;
    interface Rf1aPhysical;
  }
} implementation {
  
  bool active;
  error_t result__;

  task void nextState_task()
  {
    error_t rc;
    
    if (active) {
      atomic rc =  result__;
      printf("Send got %d\r\n", rc);
      rc = call Rf1aResource.release();
      printf("Release got %d\r\n", rc);
      if (SUCCESS == rc) {
        active = FALSE;
        call Alarm.start(10);
      }
    } else {
      rc = call Rf1aResource.immediateRequest();
      printf("Request got %d\r\n", rc);
      if (SUCCESS == rc) {
        do {
          rc = call Rf1aPhysical.send(&rc, sizeof(rc));
          printf("Send got %d\r\n", rc);
        } while (SUCCESS != rc);
      }
      if (SUCCESS == rc) {
        active = TRUE;
      }
    }
  }
  
  async event void Alarm.fired () { post nextState_task(); }

  event void Rf1aResource.granted () { }

  async event void Rf1aPhysical.sendDone (int result)
  {
    atomic result__ = result;
    post nextState_task();
  }

  async event void Rf1aPhysical.receiveStarted (unsigned int length) { }
  async event void Rf1aPhysical.receiveDone (uint8_t* buffer,
                                             unsigned int count,
                                             int result) { }
  async event void Rf1aPhysical.receiveBufferFilled (uint8_t* buffer,
                                                     unsigned int count) { }
  async event void Rf1aPhysical.frameStarted () { }
  async event void Rf1aPhysical.clearChannel () { }
  async event void Rf1aPhysical.carrierSense () { }
  async event void Rf1aPhysical.released () { }

  event void Boot.booted () {
    post nextState_task();
  }
}
