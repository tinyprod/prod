
#include "Msp430Pmm.h"

/**
 * Power Management Module
 * @author David Moss
 */

configuration Msp430PmmC {
  provides {
    interface Init;
    interface Pmm;
  }
}

implementation {

  components Msp430PmmP;
  Init = Msp430PmmP;
  Pmm = Msp430PmmP;
  
}
