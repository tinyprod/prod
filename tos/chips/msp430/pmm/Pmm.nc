

/**
 * Power Management Interface 
 * @author David Moss
 */

interface Pmm {
  
  /**
   * Set the voltage level of the MSP430x core
   *  0x0 => DVcc > 1.8V
   *  0x1 => DVcc > 2.0V
   *  0x2 => DVcc > 2.2V
   *  0x3 => DVcc > 2.4V
   *
   * The CC1101 radio core requires 0x2.
   * @param level The voltage level between 0-3
   */
  command void setVoltage(uint8_t level);
}
