#ifndef PACKET_TIMESYNC_H
#define PACKET_TIMESYNC_H

#ifndef AM_TIMESYNCMSG
#define AM_TIMESYNCMSG 0x3D
#endif

typedef nx_struct {
	nx_am_id_t type;
	nx_uint32_t eventTime;
} chipcon_timesync_header_t;

#endif