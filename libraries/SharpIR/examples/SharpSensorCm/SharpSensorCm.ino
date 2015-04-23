#include <SharpIR.h>

#define ir A0
#define model 1080

boolean done=false;


SharpIR sharp(ir, 25, 93, model);

// ir: the pin where your sensor is attached
// 25: the number of readings the library will make before calculating a mean distance
// 93: the difference between two consecutive measurements to be taken as valid
// model: an int that determines your sensor:  1080 for GP2Y0A21Y
//                                            20150 for GP2Y0A02Y
//                                            (working distance range according to the datasheets)

/*	
The circuit:
	* +V connection of the PING))) attached to +5V
	* GND connection of the PING))) attached to ground
	* SIG connection of the PING))) attached to digital pin 7
*/

// this constant won't change.  It's the pin number
// of the sensor's output:

const int trigger = 3;
const int echo = 2;

void setup(){

	Serial.begin(115200);
	pinMode (ir, INPUT);
	pinMode(trigger, OUTPUT);
	digitalWrite(trigger, LOW);
	pinMode(echo, INPUT);
	digitalWrite(echo, LOW);  
}

void loop(){

	delay(100);    // it gives you time to open the serial monitor after you upload the sketch
	unsigned long pepe1=millis();  // takes the time before the loop on the library begins
	int dis=sharp.distance()*0.393701;  // this returns the distance to the object you're measuring
	
//	Serial.print("Mean distance: ");  // returns it to the serial monitor
	Serial.print(dis);
	Serial.print(",");

	long duration, inches;
	trigger_pulse();
	duration = pulseIn(echo, HIGH, 36000);

	// convert the time into a distance
	inches = microsecondsToInches(duration);

	Serial.println(inches);
}

long microsecondsToInches(long microseconds)
{
	// According to Parallax's datasheet for the PING))), there are
	// 73.746 microseconds per inch (i.e. sound travels at 1130 feet per
	// second).  This gives the distance travelled by the ping, outbound
	// and return, so we divide by 2 to get the distance of the obstacle.
	// See: http://www.parallax.com/dl/docs/prod/acc/28015-PING-v1.3.pdf
	return microseconds / 74 / 2;
}

void trigger_pulse()
{
	// The PING))) is triggered by a HIGH pulse of 10 or more microseconds.
	// Give a short LOW pulse beforehand to ensure a clean HIGH pulse:

	// The same pin is used to read the signal from the PING))): a HIGH
	// pulse whose duration is the time (in microseconds) from the sending
	// of the ping to the reception of its echo off of an object.

	digitalWrite(trigger, LOW);
	delayMicroseconds(2);
	digitalWrite(trigger, HIGH);
	delayMicroseconds(10);
	digitalWrite(trigger, LOW);
}