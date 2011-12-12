#ifndef LOW_POWER_LISTENING_H 
#define LOW_POWER_LISTENING_H

#ifndef LPL_DEFAULT_INTERVAL
#define LPL_DEFAULT_INTERVAL 0
#endif

typedef struct {
	uint32_t timeOn;		// time spent (in ms) with the radio on
	uint32_t timeTotal;	// total time (in ms) since boot (or clock wraparound)
} cc_lpl_status_t;

enum {
	CCA_SETTLING_TIME = 1,		// time to wait before sampling CCA after turning the radio on
	LPL_PREAMBLE_OVERLAP = 5,	// fixed time (in ms) to add to the receiver's sleep interval to allow for timing jitter; TODO tweak	
};

#define CALIBRATION_INTERVAL 60*1000U		// calibrate the radio every minute

#endif
