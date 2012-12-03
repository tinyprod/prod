#include "fake_tunit.h"

module TestP {
  uses {
    interface Boot;
    interface Leds;
    interface KeyValueRecord as KVR1;
    interface KeyValueRecord as KVR2;
    interface KeyValueRecord as KVR3;
  }
}

implementation {

#include "KeyValueRecordP.h"

  event void Boot.booted() {
    int i = 0;

    printf("KeyValueRecord test 2\n");
    assertEqual(call KVR1.numClients_(), 3);
    assertEqual(call KVR2.numClients_(), 3);
    assertEqual(call KVR3.numClients_(), 3);

    assertEqual(call KVR1.historySize_(), 0);
    assertEqual(call KVR2.historySize_(), 0);
    assertEqual(call KVR3.historySize_(), 0);

    call KVR1.insert(1, 0);
    assertEqual(call KVR1.historySize_(), 1);
    assertEqual(call KVR2.historySize_(), 0);
    assertEqual(call KVR3.historySize_(), 0);

    assertTrue(call KVR1.hasSeen(1, 0));
    assertTrue(! call KVR2.hasSeen(1, 0));
    assertTrue(! call KVR3.hasSeen(1, 0));

    i = 0;
    while (i < KEYVALUERECORD_HISTORY_SIZE) {
      call KVR2.insert(1, i);
      ++i;
      assertEqual(call KVR2.historySize_(), i);
    }
    assertEqual(call KVR1.historySize_(), 1);
    assertEqual(call KVR2.historySize_(), KEYVALUERECORD_HISTORY_SIZE);
    assertEqual(call KVR3.historySize_(), 0);
    assertTrue(call KVR1.hasSeen(1, 0));
    assertTrue(call KVR2.hasSeen(1, 0));
    assertTrue(! call KVR3.hasSeen(1, 0));

    while (i < 2*KEYVALUERECORD_HISTORY_SIZE) {
      call KVR2.insert(1, i);
      ++i;
      assertEqual(call KVR2.historySize_(), KEYVALUERECORD_HISTORY_SIZE);
    }
    assertEqual(call KVR1.historySize_(), 1);
    assertEqual(call KVR2.historySize_(), KEYVALUERECORD_HISTORY_SIZE);
    assertEqual(call KVR3.historySize_(), 0);
    assertTrue(call KVR1.hasSeen(1, 0));
    assertTrue(! call KVR2.hasSeen(1, 0));
    assertTrue(! call KVR3.hasSeen(1, 0));

  }
  
}
