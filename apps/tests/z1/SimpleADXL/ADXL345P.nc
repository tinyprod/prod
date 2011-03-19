#include "ADXL345.h"


module ADXL345P {
   provides {
	interface SplitControl;
   	interface Read<uint16_t> as X;
   	interface Read<uint16_t> as Y;
   	interface Read<uint16_t> as Z;
   	interface ADXL345Control;
   }
   uses {
    interface Leds;
  	interface Resource;
  	interface ResourceRequested;
  	interface I2CPacket<TI2CBasicAddr> as I2CBasicAddr;        
  }
   
}
implementation {
  
  norace uint8_t state;
  norace uint8_t adxlcmd;
  norace uint8_t databuf[10];
  norace uint8_t pointer;
  norace uint16_t x_axis;
  norace uint16_t y_axis;
  norace uint16_t z_axis;
  norace uint8_t dataformat;
  
  task void started(){
  	signal SplitControl.startDone(SUCCESS);
  }
  
  task void stopped(){
  
  }
  
  task void calculateX(){
  	signal X.readDone(SUCCESS, x_axis);
  }

  task void calculateY(){
  	signal Y.readDone(SUCCESS, y_axis);
  }

  task void calculateZ(){
  	signal Z.readDone(SUCCESS, z_axis);
  }

  task void rangeDone(){
  	signal ADXL345Control.setRangeDone();
  }

  command error_t SplitControl.start(){
  	adxlcmd = ADXLCMD_START;
  	call Resource.request();
  	return SUCCESS;
  }
  
  command error_t SplitControl.stop(){
  	return SUCCESS;
  }
  
  command error_t ADXL345Control.setRange(uint8_t range, uint8_t resolution){
  	adxlcmd = ADXLCMD_RANGE;
  	dataformat = resolution << 3;
  	dataformat = dataformat + range;
  	printfUART("dataformat %x\n", dataformat);
  	call Resource.request();
  	return SUCCESS;
  }
  
  command error_t X.read(){
    adxlcmd = ADXLCMD_READ_X;
    call Resource.request();
	return SUCCESS;
  }

  command error_t Y.read(){
    adxlcmd = ADXLCMD_READ_Y;
    call Resource.request();
	return SUCCESS;
  }

  command error_t Z.read(){
    adxlcmd = ADXLCMD_READ_Z;
    call Resource.request();
	return SUCCESS;
  }

  event void Resource.granted(){
  	switch(adxlcmd){
  		case ADXLCMD_START:
		  	databuf[0] = ADXL345_POWER_CTL;
		  	databuf[1] = ADXL345_MEASURE_MODE;
			call I2CBasicAddr.write((I2C_START | I2C_STOP), ADXL345_ADDRESS, 2, databuf); 
  			break;
  			
  		case ADXLCMD_READ_X:
		   	pointer = ADXL345_DATAX0;
		   	call I2CBasicAddr.write((I2C_START | I2C_STOP), ADXL345_ADDRESS, 1, &pointer); 
  			break;

  		case ADXLCMD_READ_Y:
		   	pointer = ADXL345_DATAY0;
		   	call I2CBasicAddr.write((I2C_START | I2C_STOP), ADXL345_ADDRESS, 1, &pointer); 
  			break;

  		case ADXLCMD_READ_Z:
		   	pointer = ADXL345_DATAZ0;
		   	call I2CBasicAddr.write((I2C_START | I2C_STOP), ADXL345_ADDRESS, 1, &pointer); 
  			break;
  		
  		case ADXLCMD_RANGE:
  			databuf[0] = ADXL345_DATAFORMAT;
  			databuf[1] = dataformat;
  			call I2CBasicAddr.write((I2C_START | I2C_STOP), ADXL345_ADDRESS, 2, databuf);
  			break;
  	}
  }
  
  async event void ResourceRequested.requested(){
  	
  }
  
  async event void ResourceRequested.immediateRequested(){
  
  }
  
  async event void I2CBasicAddr.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t *data){
	uint16_t tmp;
    if(call Resource.isOwner()) {
		switch(adxlcmd){
			case ADXLCMD_READ_X:
	  			call Resource.release();
				//printfUART("tmpx %d - %d\n", data[1], data[0]);
			  	tmp = data[1];
	  			tmp = tmp << 8;
	  			tmp = tmp + data[0];
	  			x_axis = tmp;
	  			post calculateX();
	  			break;
	
			case ADXLCMD_READ_Y:
	  			call Resource.release();
	  			//printfUART("tmpy %d - %d\n", data[1], data[0]);
			  	tmp = data[1];
	  			tmp = tmp << 8;
	  			tmp = tmp + data[0];
	  			y_axis = tmp;
	  			post calculateY();
	  			break;
	
			case ADXLCMD_READ_Z:
	  			call Resource.release();
	  			//printfUART("tmpz %d - %d\n", data[1], data[0]);
			  	tmp = data[1];
	  			tmp = tmp << 8;
	  			tmp = tmp + data[0];
	  			z_axis = tmp;
	  			post calculateZ();
	  			break;
		}
	}
  }

  async event void I2CBasicAddr.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t *data){
    if(call Resource.isOwner()) {
	  	switch(adxlcmd){
	  		case ADXLCMD_START:
	  			//nothing to do
	  			call Resource.release();
	  			post started();
	  			break;
	  			
	  		case ADXLCMD_READ_X:
	  			call I2CBasicAddr.read((I2C_START | I2C_STOP),  ADXL345_ADDRESS, 2, databuf);	
	  			break;
	
	  		case ADXLCMD_READ_Y:
	  			call I2CBasicAddr.read((I2C_START | I2C_STOP),  ADXL345_ADDRESS, 2, databuf);	
	  			break;
	  			
	  		case ADXLCMD_READ_Z:
	  			call I2CBasicAddr.read((I2C_START | I2C_STOP),  ADXL345_ADDRESS, 2, databuf);	
	  			break;
	  		
	  		case ADXLCMD_RANGE:
	  			call Resource.release();
	  			post rangeDone();
	  			break;
	  	}
	 }
  }   
  
  /* default handlers */
  default event void X.readDone(error_t error, uint16_t data){
  	return;
  }	  
  
  default event void Y.readDone(error_t error, uint16_t data){
  	return;
  }	  
  
  default event void Z.readDone(error_t error, uint16_t data){
  	return;
  }	  
  
}
