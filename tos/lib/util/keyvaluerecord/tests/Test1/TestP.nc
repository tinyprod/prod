#include "fake_tunit.h"

module TestP {
  uses {
    interface Boot;
    interface KeyValueRecord as KVR1;
  }
}

implementation {

#include "KeyValueRecordP.h"

  event void Boot.booted() {
    int i = 0;

    printf("KeyValueRecord test 1\n");
    assertEqual(call KVR1.numClients_(), 1);
    assertEqual(call KVR1.historySize_(), 0);

    // Have not seen zero/zero, even at startup
    assertTrue(! call KVR1.hasSeen(0, 0));

    // Base test
    assertTrue(! call KVR1.hasSeen(1, 0));

    // Fill history
    while (i < KEYVALUERECORD_HISTORY_SIZE) {
      call KVR1.insert(1, i);
      assertEqual(call KVR1.historySize_(), i+1);
      assertTrue(! call KVR1.hasSeen(0, 0));
      assertTrue(call KVR1.hasSeen(1, 0));
      assertTrue(call KVR1.hasSeen(1, i));
      ++i;
    }

    // Test FIFO ejection
    assertEqual(call KVR1.historySize_(), KEYVALUERECORD_HISTORY_SIZE);
    assertTrue(call KVR1.hasSeen(1, 0));
    assertTrue(! call KVR1.hasSeen(1, i));
    call KVR1.insert(1, i);
    assertEqual(call KVR1.historySize_(), KEYVALUERECORD_HISTORY_SIZE);
    assertTrue(! call KVR1.hasSeen(1, 0));
    assertTrue(call KVR1.hasSeen(1, i));
  }
  
}
