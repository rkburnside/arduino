//servo controlled aerosol gag
//this worked fairly well...on Dan

#include <Servo.h> 
#include <stdlib.h>

float distance_cm = 0.0, distance_in = 0.0, voltage = 0.0; //declares all necessary variables
int IR_input = 0; //sets a variable for the IR distance sensor pin
char buffer[25]; //buffer for the dtostrf function
Servo myservo;
int ledPin =  13;    // LED connected to digital pin 13

void setup() 
{ 
	pinMode(ledPin, OUTPUT);     
	myservo.attach(10);
//	Serial.begin(9600); //enables serial communication
//	Serial.println("voltage\t  distance_cm\tdistance_in\ttriggered"); //prints column headers
	myservo.write(170);
	digitalWrite(ledPin, LOW);    // set the LED off
} 

void loop()
{
	voltage = 5.0 * analogRead(IR_input) / 1023.0; //reads the IR pin and returns a value between 0 & 1023
	distance_cm = 26.282 * pow(voltage,-1.254);
//	distance_in = distance_cm * 0.393700787; //cm to in conversion
//	Serial.print(dtostrf(voltage,5,3,buffer));
//	Serial.print("\t       ");
//	Serial.print(dtostrf(distance_cm,5,2,buffer));
//	Serial.print("\t      ");
//	Serial.print(dtostrf(distance_in,5,2,buffer));

	if(distance_cm<92)
	{
		Serial.print("\t   servo triggered");
		trigger();
	}

//	Serial.println("");
	delay(100);
}

void trigger(void)
{
	digitalWrite(ledPin, HIGH);   // set the LED on
	myservo.write(30);
	delay(1000);
	myservo.write(170);
	digitalWrite(ledPin, LOW);   // set the LED on
	delay(1000);
}