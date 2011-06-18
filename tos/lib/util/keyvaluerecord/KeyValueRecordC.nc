

/**
 * This component will temporarily log key/value pairs.  You can insert
 * a key/value pair, and then check back later to see if you recently 
 * inserted some pair.  As more key/value pairs are added, the oldest ones
 * fall off.
 *
 * The real purpose is to do duplicate packet filtering, where a node with some
 * address (the key) will some some data sequence number (the value).
 * For every packet received, we log the address and DSN.  If we receive another
 * packet, we can check back in our log to see if the packet is a duplicate.
 * 
 * This the value doesn't have to be a data sequence number.  For duplicate
 * payload filtering, the value can be a CRC of the received data. Keep in
 * mind that if this is used in two separate areas of an application, there
 * could occasionally be conflicts where key/value pairs from one context
 * might be the same as key/value pairs inserted from a different context.
 * 
 * @author David Moss
 */
 
#include "KeyValueRecord.h"

generic configuration KeyValueRecordC() {
  provides {
    interface KeyValueRecord;
  }
}

implementation {

  components KeyValueRecordP;
  KeyValueRecord = KeyValueRecordP.KeyValueRecord[unique(UQ_KEYVALUERECORD)];
  
}
