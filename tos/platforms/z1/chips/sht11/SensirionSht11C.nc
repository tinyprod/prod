
generic configuration SensirionSht11C() {
  provides interface Read<uint16_t> as Temperature;
  provides interface DeviceMetadata as TemperatureMetadata;
  provides interface Read<uint16_t> as Humidity;
  provides interface DeviceMetadata as HumidityMetadata;
}
implementation {
  components new SensirionSht11ReaderP();

  Temperature = SensirionSht11ReaderP.Temperature;
  TemperatureMetadata = SensirionSht11ReaderP.TemperatureMetadata;
  Humidity = SensirionSht11ReaderP.Humidity;
  HumidityMetadata = SensirionSht11ReaderP.HumidityMetadata;

  components HalSensirionSht11C;

  enum { TEMP_KEY = unique("Sht11.Resource") };
  enum { HUM_KEY = unique("Sht11.Resource") };

  SensirionSht11ReaderP.TempResource -> HalSensirionSht11C.Resource[ TEMP_KEY ];
  SensirionSht11ReaderP.Sht11Temp -> HalSensirionSht11C.SensirionSht11[ TEMP_KEY ];
  SensirionSht11ReaderP.HumResource -> HalSensirionSht11C.Resource[ HUM_KEY ];
  SensirionSht11ReaderP.Sht11Hum -> HalSensirionSht11C.SensirionSht11[ HUM_KEY ];
}
