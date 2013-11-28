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

void setup()
{
	Serial.begin(9600);
	pinMode(trigger, OUTPUT);
	digitalWrite(trigger, LOW);
	pinMode(echo, INPUT);
	digitalWrite(echo, LOW);
}

void loop()
{
	long duration, inches;

	trigger_pulse();

	duration = pulseIn(echo, HIGH, 36000);

	// convert the time into a distance
	inches = microsecondsToInches(duration);

	Serial.print(inches);
	Serial.print("in, ");
//	Serial.print(cm);
//	Serial.print("cm");
	Serial.println();

	delay(100);
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