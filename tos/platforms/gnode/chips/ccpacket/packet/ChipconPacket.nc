#include "message.h"
#include "ChipconPacket.h"

/**
 * Provides access to the packet header, footer and metadata.
 */
interface ChipconPacket {
	async command chipcon_header_t* getHeader(message_t* msg);
	async command chipcon_footer_t* getFooter(message_t* msg);
	async command chipcon_metadata_t* getMetadata(message_t* msg);
	async command uint8_t getPacketLength(message_t* msg);
	async command uint8_t getPayloadLength(message_t* msg);
	async command void setPayloadLength(message_t* msg, uint8_t len);
}
