/* What the hell is this supposed to do? */
uint16_t adjustLQI(uint8_t val) {
  uint16_t result = (80 - (val - 50));
  result = (((result * result) >> 3) * result) >> 3;  // result = (result ^ 3) / 64
  return result;
}

module Rf1aReadLqiC {
  provides interface ReadLqi;
  uses interface Rf1aPacket;
} implementation {
  command uint8_t ReadLqi.read(message_t *msg) {
    return call Rf1aPacket.getLqi(msg);
  }
}
