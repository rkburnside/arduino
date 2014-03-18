//this is just code for adelle's robot

#include "AFMotor.h"
#include <Servo.h>

// two stepper motors one on each port
AF_Stepper motor1(200, 1);
AF_Stepper motor2(200, 2);

//servo declaration
Servo servo1;

void setup(){
	pinMode(A5, OUTPUT);      // sets the digital pin as output
	digitalWrite(A5, HIGH);   // sets the LED on

	servo1.attach(9);
	motor1.setSpeed(10);  // 10 rpm
	motor2.setSpeed(10);  // 10 rpm

	motor1.release();
	motor2.release();
	
	delay(2500);
}

void loop()
{
	static double time = 0;

	while((millis() - time) < 5000){
		motor1.step(1, FORWARD, INTERLEAVE);
		motor2.step(1, FORWARD, INTERLEAVE);
		servo1.write(30);
	}
	
	motor1.release();
	motor2.release();
	
	blink_led();

	time = millis();

	while((millis() - time) < 5000){
		motor1.step(1, BACKWARD, INTERLEAVE);
		motor2.step(1, BACKWARD, INTERLEAVE);
		servo1.write(150);
	}
	
	motor1.release();
	motor2.release();

	blink_led();
	
	time = millis();

	if(millis() > 300000){
			servo1.detach();
			motor1.release();
			motor2.release();
			digitalWrite(A5, LOW);   // sets the LED on
		while(1){}
	}
	
}

void blink_led(){
	servo1.detach();

	for(int i = 0; i<40; i++){
		digitalWrite(A5, !digitalRead(A5));   // sets the LED on
		delay(250);
	}

	digitalWrite(A5, HIGH);   // sets the LED on

	servo1.attach(9);
	return;
}