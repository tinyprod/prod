
/**
 * HalTMP175Advanced is the HAL control interface for the TI TMP175
 * Digital Temperature Sensor. 
 */

#include "TMP102.h"

interface HalTMP102Advanced {

  command error_t setThermostatMode(bool useInt);
  event void setThermostatModeDone(error_t error);
  command error_t setPolarity(bool polarity);
  event void setPolarityDone(error_t error);
  command error_t setFaultQueue(tmp102_fqd_t depth);
  event void setFaultQueueDone(error_t error);
  command error_t setTLow(uint16_t val);
  event void setTLowDone(error_t error);
  command error_t setTHigh(uint16_t val);
  event void setTHighDone(error_t error);
  
  //it is not possible to configure sensor resolution
  
  
  event void alertThreshold();
  
  /* We must include following modes for TMP102 */
  //conversion rate
  //extended mode
  command error_t setExtendedMode(bool extendedmode);
  event void setExtendedModeDone(error_t error);
  command error_t setConversionRate(tmp102_cr_t rate);
  event void setConversionRateDone(error_t error);


}
