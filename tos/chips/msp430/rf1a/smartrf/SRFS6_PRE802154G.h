/* Chipcon */
/* Product = CC430Fx13x */
/* Chip version = A   (HW Rev. 0x10) */
/* Crystal accuracy = 10 ppm */
/* X-tal frequency = 26 MHz */
/* RF output power = 0 dBm */
/* RX filterbandwidth = 232.142857 kHz */
/* Deviation = 25 kHz */
/* Datarate = 49.987793 kBaud */
/* Modulation = (1) GFSK */
/* Manchester enable = (0) Manchester disabled */
/* RF Frequency = 902.199921 MHz */
/* Channel spacing = 199.951172 kHz */
/* Channel number = 0 */
/* Optimization = - */
/* Sync mode = (3) 30/32 sync word bits detected */
/* Format of RX/TX data = (0) Normal mode, use FIFOs for RX and TX */
/* CRC operation = (1) CRC calculation in TX and CRC check in RX enabled */
/* Forward Error Correction = (0) FEC disabled */
/* Length configuration = (1) Variable length packets, packet length configured by the first received byte after sync word. */
/* Packetlength = 255 */
/* Preamble count = (2)  4 bytes */
/* Append status = 1 */
/* Address check = (0) No address check */
/* FIFO autoflush = 0 */
/* Device address = 0 */
/* GDO0 signal selection = ( 6) Asserts when sync word has been sent / received, and de-asserts at the end of the packet */
/* GDO2 signal selection = (41) CHIP_RDY */
#define SMARTRF_SETTING_FSCTRL1  0x08
#define SMARTRF_SETTING_FSCTRL0  0x00
#define SMARTRF_SETTING_FREQ2    0x22
#define SMARTRF_SETTING_FREQ1    0xB3
#define SMARTRF_SETTING_FREQ0    0x33
#define SMARTRF_SETTING_MDMCFG4  0x7A
#define SMARTRF_SETTING_MDMCFG3  0xF8
#define SMARTRF_SETTING_MDMCFG2  0x13
#define SMARTRF_SETTING_MDMCFG1  0x22
#define SMARTRF_SETTING_MDMCFG0  0xF8
#define SMARTRF_SETTING_CHANNR   0x00
#define SMARTRF_SETTING_DEVIATN  0x40
#define SMARTRF_SETTING_FREND1   0xB6
#define SMARTRF_SETTING_FREND0   0x10
#define SMARTRF_SETTING_MCSM0    0x18
#define SMARTRF_SETTING_FOCCFG   0x1D
#define SMARTRF_SETTING_BSCFG    0x1C
#define SMARTRF_SETTING_AGCCTRL2 0xC7
#define SMARTRF_SETTING_AGCCTRL1 0x00
#define SMARTRF_SETTING_AGCCTRL0 0xB2
#define SMARTRF_SETTING_FSCAL3   0xEA
#define SMARTRF_SETTING_FSCAL2   0x2A
#define SMARTRF_SETTING_FSCAL1   0x00
#define SMARTRF_SETTING_FSCAL0   0x1F
#define SMARTRF_SETTING_FSTEST   0x59
#define SMARTRF_SETTING_TEST2    0x81
#define SMARTRF_SETTING_TEST1    0x35
#define SMARTRF_SETTING_TEST0    0x09
#define SMARTRF_SETTING_FIFOTHR  0x47
#define SMARTRF_SETTING_IOCFG2   0x29
#define SMARTRF_SETTING_IOCFG0D  0x06
#define SMARTRF_SETTING_PKTCTRL1 0x04
#define SMARTRF_SETTING_PKTCTRL0 0x05
#define SMARTRF_SETTING_ADDR     0x00
#define SMARTRF_SETTING_PKTLEN   0xFF
