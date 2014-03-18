//this is just code for adelle's robot

#include "AFMotor.h"
#include <Servo.h>

// two stepper motors one on each port
AF_Stepper motor1(200, 1);
AF_Stepper motor2(200, 2);

//servo declaration
Servo servo1;

void setup()
{
	pinMode(A5, OUTPUT);      // sets the digital pin as output

	digitalWrite(A5, HIGH);   // sets the LED on

	servo1.attach(9);
	motor1.setSpeed(10);  // 10 rpm   
	motor1.step(5, FORWARD, SINGLE); 

	motor2.setSpeed(10);  // 10 rpm   
	motor2.step(15, FORWARD, SINGLE); 

	motor1.release();
	motor2.release();
	delay(1000);
}

void loop()
{
	static int time = 0;
	
	motor1.step(1, FORWARD, SINGLE); 
	motor2.step(1, BACKWARD, SINGLE); 
	motor1.release();
	motor2.release();
	
	if((millis() - time) > 2500){
		motor1.release();
		motor2.release();
		servo1.write(150);
		delay(10000);
		time = millis();
	}
	else{
		servo1.write(30);
	}

}