interface HplMsp430UsciB{
  async command uint8_t getI2cie();
  async command void setI2cie(uint8_t v);
  async command uint16_t getI2coa();
  async command void setI2coa(uint16_t v);
  async command uint16_t getI2csa();
  async command void setI2csa(uint16_t v);
}
