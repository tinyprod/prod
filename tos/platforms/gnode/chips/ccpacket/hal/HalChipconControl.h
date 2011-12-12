#ifndef HAL_CHIPCON_CONTROL_H
#define HAL_CHIPCON_CONTROL_H

typedef struct {
	uint32_t txCount;			// number of packets transmitted
	uint32_t rxCount;		// number of packets received
	uint32_t dropCount;	// number of packets dropped
	uint8_t errorCount;		// number of detected non-fatal errors
} cc_hal_status_t;

#endif
