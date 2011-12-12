#include "msp430_ports.h"

/**
 * Provides GPIO and interrupts by number, i.e. port 1.5 is GeneralIO[15].
 * GeneralIO[00] and GeneralIO[01] are virtual (dummy) pins, initialized to a low (0)
 * and high (1) level respectively. 
 */
configuration Msp430GeneralIOC {
	provides {
		interface Init;
		interface GeneralIO[uint8_t pin];
		interface GpioInterrupt[uint8_t pin];
	}
}

implementation {

	components Msp430GeneralIOP;
	Init = Msp430GeneralIOP;
	
	components
		new DummyGeneralIOC(FALSE) as DummyLow,
		new DummyGeneralIOC(TRUE) as DummyHigh;
	
	GeneralIO[00] = DummyLow;
	GeneralIO[01] = DummyHigh;
	GpioInterrupt[00] = DummyLow;
	GpioInterrupt[01] = DummyHigh;
	
	components HplMsp430GeneralIOC as IO;
	components HplMsp430InterruptC as Interrupts;
	
#define IO_PORT(port) \
	IO_PORT_PIN(port, 0); \
	IO_PORT_PIN(port, 1); \
	IO_PORT_PIN(port, 2); \
	IO_PORT_PIN(port, 3); \
	IO_PORT_PIN(port, 4); \
	IO_PORT_PIN(port, 5); \
	IO_PORT_PIN(port, 6); \
	IO_PORT_PIN(port, 7)
	
#define IO_PORT_PIN(port, pin) \
	components new Msp430GpioC() as GeneralIO ## port ## pin; \
	GeneralIO ## port ## pin -> IO.Port ## port ## pin; \
	GeneralIO[port ## pin] = GeneralIO ## port ## pin;
	
#define INTERRUPT_PORT(port) \
	INTERRUPT_PORT_PIN(port, 0); \
	INTERRUPT_PORT_PIN(port, 1); \
	INTERRUPT_PORT_PIN(port, 2); \
	INTERRUPT_PORT_PIN(port, 3); \
	INTERRUPT_PORT_PIN(port, 4); \
	INTERRUPT_PORT_PIN(port, 5); \
	INTERRUPT_PORT_PIN(port, 6); \
	INTERRUPT_PORT_PIN(port, 7)
	
#define INTERRUPT_PORT_PIN(port, pin) \
	components new Msp430InterruptC() as GpioInterrupt ## port ## pin; \
	GpioInterrupt ## port ## pin -> Interrupts.Port ## port ## pin; \
	GpioInterrupt[port ## pin] = GpioInterrupt ## port ## pin
	
#ifdef MSP430_HAS_PORT_1
	IO_PORT(1);
#endif
	
#ifdef MSP430_HAS_PORT_2
	IO_PORT(2);
#endif
	
#ifdef MSP430_HAS_PORT_3
	IO_PORT(3);
#endif
	
#ifdef MSP430_HAS_PORT_4
	IO_PORT(4);
#endif
	
#ifdef MSP430_HAS_PORT_5
	IO_PORT(5);
#endif
	
#ifdef MSP430_HAS_PORT_6
	IO_PORT(6);
#endif
	
#ifdef MSP430_HAS_PORT_1
	INTERRUPT_PORT(1);
#endif
	
#ifdef MSP430_HAS_PORT_2
	INTERRUPT_PORT(2);
#endif
	
}
