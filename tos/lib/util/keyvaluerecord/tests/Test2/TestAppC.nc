#include "stdio.h"

configuration TestAppC {
}

implementation {

  components TestP;

  components new KeyValueRecordC() as KVR1C;
  TestP.KVR1 -> KVR1C;
  components new KeyValueRecordC() as KVR2C;
  TestP.KVR2 -> KVR2C;
  components new KeyValueRecordC() as KVR3C;
  TestP.KVR3 -> KVR3C;

  components MainC;
  TestP.Boot -> MainC;

  components SerialPrintfC;
}
