/*
This sketch is for the following purposes:
1. verify the read speed of I2C (should be 100-khz) - fastest that i can get measurements from the compass is ~500 samples per second. that's monopolizing the arduino
2. try to enable fast mode (400-khz vs 100-khz) and see if the communications between the various sensors / boards can support that speed
*/

#include <Wire.h>
#include <HMC.h>
int a;

void setup(){
	Serial.begin(115200);
//	TWBR = ((CPU_FREQ / 400000L) - 16) / 2;
}

void loop(){
	int x, y, z;
	Serial.print("t1:   ");
	Serial.print(micros());
	HMC.getValues(&x,&y,&z);
	Serial.print("   t2:   ");
	Serial.print(micros());
	Serial.print("   x:   ");
	Serial.println(x);
	delay(100);
}