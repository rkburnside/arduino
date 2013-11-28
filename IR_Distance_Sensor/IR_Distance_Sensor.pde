/*
Distance sensor
- red is connected to 5V connection
- black is connected to GND
- white is connected to Pin 1 (analog in)

used the function from stdlib.h - dtostrf(FLOAT,WIDTH,PRECSISION,BUFFER);

Next project should include the "graph" function and it "processing" compent
*/

#include <stdlib.h>

float distance_cm = 0.0, distance_in = 0.0, distance_ft = 0.0, voltage = 0.0; //declares all necessary variables
int IR_input = 15; //sets a variable for the IR distance sensor pin
char buffer[25]; //buffer for the dtostrf function

void setup()
{
	Serial.begin(9600); //enables serial communication
	Serial.println("voltage\t  distance_cm\tdistance_in\tdistance_ft"); //prints column headers
}

void loop()
{
	voltage = 5.0 * analogRead(IR_input) / 1023.0; //reads the IR pin and returns a value between 0 & 1023
	distance_cm = 26.282 * pow(voltage,-1.254);
	distance_in = distance_cm * 0.393700787; //cm to in conversion
	distance_ft = distance_in / 12; //in to ft conversion
	Serial.print(dtostrf(voltage,5,3,buffer));
	Serial.print("\t       ");
	Serial.print(dtostrf(distance_cm,5,2,buffer));
	Serial.print("\t      ");
	Serial.print(dtostrf(distance_in,5,2,buffer));
	Serial.print("\t      ");
	Serial.println(dtostrf(distance_ft,5,2,buffer));
	delay(1000);
}

