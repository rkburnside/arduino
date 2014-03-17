#include "AccelStepper.h"
#include "AFMotor.h"
#include <Servo.h>

// two stepper motors one on each port
AF_Stepper motor1(200, 1);
AF_Stepper motor2(200, 2);

//servo declaration
Servo servo1;

// you can change these to DOUBLE or INTERLEAVE or MICROSTEP!
// wrappers for the first motor!
void forwardstep1() {
	motor1.onestep(FORWARD, INTERLEAVE);
}
void backwardstep1() {
	motor1.onestep(BACKWARD, INTERLEAVE);
}
// wrappers for the second motor!
void forwardstep2() {
	motor2.onestep(FORWARD, INTERLEAVE);
}
void backwardstep2() {
	motor2.onestep(BACKWARD, INTERLEAVE);
}

// Motor shield has two motor ports, now we'll wrap them in an AccelStepper object
AccelStepper stepper1(forwardstep1, backwardstep1);
AccelStepper stepper2(forwardstep2, backwardstep2);

void setup()
{
	servo1.attach(9);
	stepper1.setMaxSpeed(200.0);
	stepper1.setAcceleration(100.0);
	stepper1.moveTo(-10000);
	
	stepper2.setMaxSpeed(50.0);
	stepper2.setAcceleration(100.0);
	stepper2.moveTo(10000);
	
}

void loop()
{
	// Change direction at the limits
	if (stepper1.distanceToGo() == 0)
	stepper1.moveTo(-stepper1.currentPosition());
	stepper1.run();
	stepper2.run();

}
