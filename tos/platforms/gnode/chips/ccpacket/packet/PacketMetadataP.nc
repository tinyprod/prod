#include "ChipconRegisterValues.h"

/**
 * Provide metadata for CC1100 packets.
 */
module PacketMetadataP {
	provides interface PacketMetadata;
	uses interface ChipconPacket;
}

implementation {

	command int16_t PacketMetadata.getRssi(message_t* msg) {
		// the raw output is in units of 1/2 dBm with an  added offset,
		// which depends on the frequency and data rate
		int16_t rssi = (call ChipconPacket.getMetadata(msg))->rssi;
		if (rssi > 127) rssi -= 256;
		return rssi/2 - RSSI_OFFSET;
	}
	
	command int16_t PacketMetadata.getLqi(message_t* msg) {
		return (call ChipconPacket.getMetadata(msg))->crcAndLqi & 0x7F;
	}
}
