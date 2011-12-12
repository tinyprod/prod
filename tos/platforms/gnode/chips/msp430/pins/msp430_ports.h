#ifndef MSP430_PORTS_H
#define MSP430_PORTS_H

// define unified names for the various ways of specifying available ports

#if defined(__msp430_have_port1) || defined(__MSP430_HAS_PORT1__) || defined(__MSP430_HAS_PORT1_R__)
#define MSP430_HAS_PORT_1
#endif

#if defined(__msp430_have_port2) || defined(__MSP430_HAS_PORT2__) || defined(__MSP430_HAS_PORT2_R__)
#define MSP430_HAS_PORT_2
#endif

#if defined(__msp430_have_port3) || defined(__MSP430_HAS_PORT3__) || defined(__MSP430_HAS_PORT3_R__)
#define MSP430_HAS_PORT_3
#endif

#if defined(__msp430_have_port4) || defined(__MSP430_HAS_PORT4__) || defined(__MSP430_HAS_PORT4_R__)
#define MSP430_HAS_PORT_4
#endif

#if defined(__msp430_have_port5) || defined(__MSP430_HAS_PORT5__) || defined(__MSP430_HAS_PORT5_R__)
#define MSP430_HAS_PORT_5
#endif

#if defined(__msp430_have_port6) || defined(__MSP430_HAS_PORT6__) || defined(__MSP430_HAS_PORT6_R__)
#define MSP430_HAS_PORT_6
#endif

#endif
