#include "msp430_ports.h"

module Msp430GeneralIOP {
	provides interface Init;
}

implementation {

	/**
	 * Reset all of the ports to be input and using I/O functionality.
	 */
	command error_t Init.init() {
		atomic {
#ifdef MSP430_HAS_PORT_1
			P1SEL = 0;
			P1DIR = 0;
			P1OUT = 0;
			P1IE = 0;
#endif

#ifdef MSP430_HAS_PORT_2
			P2SEL = 0;
			P2DIR = 0;
			P2OUT = 0;
			P2IE = 0;
#endif

#ifdef MSP430_HAS_PORT_3
			P3SEL = 0;
			P3DIR = 0;
			P3OUT = 0;
#endif

#ifdef MSP430_HAS_PORT_4
			P4SEL = 0;
			P4DIR = 0;
			P4OUT = 0;
#endif

#ifdef MSP430_HAS_PORT_5
			P5SEL = 0;
			P5DIR = 0;
			P5OUT = 0;
#endif

#ifdef MSP430_HAS_PORT_6
			P6SEL = 0;
			P6DIR = 0;
			P6OUT = 0;
#endif
		}
		
		return SUCCESS;
	}
}
