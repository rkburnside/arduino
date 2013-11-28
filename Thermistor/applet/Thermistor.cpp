//Schematic:
// [Ground] ---- [10k-Resister] -------|------- [Thermistor] ---- [+5v]
//                                     |
//                                Analog Pin 0

#include <math.h>
#define CONST_A 0.003354559
#define CONST_B 0.00025903082
#define CONST_C 0.0000041929419
#define CONST_D -0.000000071497776

#include "WProgram.h"
void setup();
void loop();
double voltage(int rawADC);
void printDouble(double val, byte precision);
double thermistor = 0;    // thermistor reading
double temperature = 0;  //temperature variable
int therm_pin = 5;	//thermistor pin
int time = 300;  //dealy time
double temp = 0;
double kelvin = 0;
double celcius = 0;
double fahrenheit = 0;
double resistance = 0;
int counter = 0;

void setup()
{
	Serial.begin(9600);
	Serial.println("Ready");
}

void loop()
{
Serial.println("");
Serial.print("ADC Value");
Serial.print("\tTherm Vdrop");
Serial.print("\tR/R25");
Serial.print("\tKelvin");
Serial.print("\t  Celcius");
Serial.print("\t  Fahrenheit");
Serial.println("");

for(counter = 0; counter < 10; counter++)
{
	thermistor = analogRead(therm_pin);

	temp = (1024.0 - thermistor) / 1024;
	resistance = (1024.0/thermistor - 1) * 30000;
	temp = resistance / 30000.0;
	kelvin = 1/(CONST_A + CONST_B * log(temp) + CONST_C * pow(log(temp), 2) + CONST_D * pow(log(temp), 3));
	celcius = kelvin - 273.15;
	fahrenheit = (celcius * 9.0)/ 5.0 + 32.0;


	printDouble(thermistor, 0);
	Serial.print("\t\t");
	printDouble(voltage(thermistor), 3);
	Serial.print("\t\t");
	printDouble(temp, 3);
	Serial.print("\t");
	printDouble(kelvin, 1);
	Serial.print("\t  ");
	printDouble(celcius, 1);
	Serial.print("\t\t  ");
	printDouble(fahrenheit, 1);
	Serial.println("");
	
	delay(time);
}
}

double voltage(int rawADC)
{
  	double volts = 0;
	volts = (1024 - rawADC) / 1024.0 * 4.98;	//4.84 Volts output
	return volts;  // Return the Temperature
}


void printDouble(double val, byte precision)
{
	// prints val with number of decimal places determine by precision
	// precision is a number from 0 to 6 indicating the desired decimal places
	// example: printDouble(3.1415, 2); // prints 3.14 (two decimal places)
	Serial.print (int(val));  //prints the int part

	if( precision > 0)
	{
		Serial.print("."); // print the decimal point
		unsigned long frac, mult = 1;
		byte padding = precision -1;
		while(precision--) mult *=10;
		if(val >= 0) frac = (val - int(val)) * mult; else frac = (int(val) - val) * mult;
		unsigned long frac1 = frac;
		while(frac1 /= 10) padding--;
		while(padding--) Serial.print("0");
		Serial.print(frac,DEC) ;
	}
}


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

