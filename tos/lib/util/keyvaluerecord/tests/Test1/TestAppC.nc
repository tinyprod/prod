#include "stdio.h"

configuration TestAppC {
}

implementation {

  components TestP;

  components new KeyValueRecordC() as KVR1C;
  TestP.KVR1 -> KVR1C;

  components MainC;
  TestP.Boot -> MainC;

  components SerialPrintfC;
}
