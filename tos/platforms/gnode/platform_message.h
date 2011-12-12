#ifndef PLATFORM_MESSAGE_H
#define PLATFORM_MESSAGE_H

#include "ChipconPacket.h"
#include "Serial.h"

typedef union message_header {
	chipcon_header_t radio;
	serial_header_t serial;
} message_header_t;

typedef union message_footer {
	chipcon_footer_t radio;
} message_footer_t;

typedef union message_metadata {
	chipcon_metadata_t radio;
} message_metadata_t;

// obsolete, but used by CTP
#define TOS_BCAST_ADDR AM_BROADCAST_ADDR

#endif
