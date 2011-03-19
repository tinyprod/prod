
configuration ADXL345C {
  provides interface SplitControl;
  provides interface Read<uint16_t> as X;
  provides interface Read<uint16_t> as Y;
  provides interface Read<uint16_t> as Z;
  provides interface ADXL345Control;
}
implementation {
  components ADXL345P;
  X = ADXL345P.X;
  Y = ADXL345P.Y;
  Z = ADXL345P.Z;
  SplitControl = ADXL345P;
  ADXL345Control = ADXL345P;
  
  components LedsC;
  ADXL345P.Leds -> LedsC;

  components new Msp430I2C1C() as I2C;
  ADXL345P.Resource -> I2C;
  ADXL345P.ResourceRequested -> I2C;
  ADXL345P.I2CBasicAddr -> I2C;    
  
}
