
#ifndef MSP430PMM_H
#define MSP430PMM_H

/**
 * A minimum level of 2 is needed for CC1101 radio operation
 * This CC1101 references the integrated CC1101 (RF1A) on
 * the cc430f5137 chip used by the surf board.
 *
 * Other chips have the PMM module so this needs to move at some point.
 */

#ifndef DEFAULT_VCORE_LEVEL
#define DEFAULT_VCORE_LEVEL 0x2
#endif

#endif
