#include "message.h"

/**
 * Provides access to (potentially radio specific) packet metadata fields. 
 */
interface PacketMetadata {

	/**
	 * Return the RSSI value for this packet, in dBm.
	 */
	command int16_t getRssi(message_t* msg);

	/**
	 * Return the LQI (link quality indicator) for this packet.
	 */
	command int16_t getLqi(message_t* msg);
}
