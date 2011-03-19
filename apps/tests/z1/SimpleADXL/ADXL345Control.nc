interface ADXL345Control
{
    command error_t setRange(uint8_t range, uint8_t resolution);
    event void setRangeDone();
}
