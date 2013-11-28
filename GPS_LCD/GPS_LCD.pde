#include <NewSoftSerial.h>
#include <TinyGPS.h>
#include <LiquidCrystal.h>
#include <stdlib.h>

/*
LCD portion of code with ouput is as follows:
Arduio pins: D7->2, D6->3, D5->4, D4->5, E1->6, RS->7
***2nd line of LCD is disabled due to limited pins and the use the SD storage***
 */

// initialize LCD library with interface pins
LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

// initialize GPS library with interface pins
TinyGPS gps;
NewSoftSerial nss(8, 1); //no transmit pin is used for the gps, therefore no pin is declared

void gpsdump(TinyGPS &gps);
bool feedgps();
void printFloat(double f, int digits = 2);


/*
Distance sensor
- red is connected to 5V connection
- black is connected to GND
- white is connected to Pin 0 (analog in)

used the function from stdlib.h - dtostrf(FLOAT,WIDTH,PRECSISION,BUFFER);
*/

float distance_cm = 0.0, distance_in = 0.0, distance_ft = 0.0, voltage = 0.0; //declares all necessary variables
int IR_input = 0; //sets a variable for the IR distance sensor pin
char buffer[25]; //buffer for the dtostrf function

void IR_sensor(void);
void GPS(void);

void setup()
{
	// set up the LCD's number of rows and columns: 
	lcd.begin(40, 2);
	lcd.clear();
	lcd.setCursor(0,0);

	Serial.begin(115200);
	nss.begin(4800);

	Serial.print("Testing TinyGPS library v. "); Serial.println(TinyGPS::library_version());
	Serial.println("by Mikal Hart");
	Serial.println();
	Serial.print("Sizeof(gpsobject) = "); Serial.println(sizeof(TinyGPS));
	Serial.println();

	lcd.print("Testing TinyGPS library v. "); lcd.println(TinyGPS::library_version());
	lcd.println("by Mikal Hart");
	lcd.println();
	lcd.print("Sizeof(gpsobject) = "); lcd.println(sizeof(TinyGPS));
	lcd.println();

	delay(2000);

}

void loop()
{
	IR_sensor();
	delay(1000);
	GPS();
	delay(1000);
}

void IR_sensor()
{
	// IR distance sensor calculations, reads the IR pin and returns a value between 0 & 1023
	voltage = 5.0 * analogRead(IR_input) / 1023.0;
	distance_cm = 26.282 * pow(voltage,-1.254); // function that converts voltage to distance
	distance_in = distance_cm * 0.393700787; //cm to in conversion
	distance_ft = distance_in / 12; //in to ft conversion

	// IR distance serial printing
	Serial.println("voltage\t  distance_cm\tdistance_in\tdistance_ft"); //prints column headers
	Serial.print(dtostrf(voltage,5,3,buffer));
	Serial.print(", ");
	Serial.print(dtostrf(distance_cm,5,2,buffer));
	Serial.print(", ");
	Serial.print(dtostrf(distance_in,5,2,buffer));
	Serial.print(", ");
	Serial.println(dtostrf(distance_ft,5,2,buffer));

	// IR distance lcd printing
	lcd.clear();
	lcd.setCursor(0,0);
	lcd.print("vltg, d_cm, d_in, d_ft"); //prints column headers
	lcd.setCursor(0,1);
	lcd.print(dtostrf(voltage,5,3,buffer));
	lcd.print(", ");
	lcd.print(dtostrf(distance_cm,5,2,buffer));
	lcd.print(", ");
	lcd.print(dtostrf(distance_in,5,2,buffer));
	lcd.print(", ");
	lcd.print(dtostrf(distance_ft,5,2,buffer));
	lcd.print("   ");

	return;	
}

void GPS()
{
	bool newdata = false;
	unsigned long start = millis();

	// Every 5 seconds we print an update
	while (millis() - start < 5000)
	{
		if (feedgps())
		newdata = true;
	}
	
	if (newdata)
	{
		Serial.println("Acquired Data");
		Serial.println("-------------");
		gpsdump(gps);
		Serial.println("-------------");
		Serial.println();
	}
}

void printFloat(double number, int digits)
{
	// Handle negative numbers
	if (number < 0.0)
	{
		Serial.print('-');
		number = -number;
	}

	// Round correctly so that print(1.999, 2) prints as "2.00"
	double rounding = 0.5;
	for (uint8_t i=0; i<digits; ++i)
	rounding /= 10.0;
	
	number += rounding;

	// Extract the integer part of the number and print it
	unsigned long int_part = (unsigned long)number;
	double remainder = number - (double)int_part;
	Serial.print(int_part);
	
	// Print the decimal point, but only if there are digits beyond
	if (digits > 0)
	Serial.print("."); 
	
	// Extract digits from the remainder one at a time
	while (digits-- > 0)
	{
		remainder *= 10.0;
		int toPrint = int(remainder);
		Serial.print(toPrint);
		remainder -= toPrint; 
	} 
}

void gpsdump(TinyGPS &gps)
{
	long lat, lon;
	float flat, flon;
	unsigned long age, date, time, chars;
	int year;
	byte month, day, hour, minute, second, hundredths;
	unsigned short sentences, failed;
	
	gps.get_position(&lat, &lon, &age);
	Serial.print("Lat/Long(10^-5 deg): "); Serial.print(lat); Serial.print(", "); Serial.print(lon);
	Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");
	
	feedgps(); // If we don't feed the gps during this long routine, we may drop characters and get checksum errors
	
	gps.f_get_position(&flat, &flon, &age);
	Serial.print("Lat/Long(float): "); printFloat(flat, 5); Serial.print(", "); printFloat(flon, 5);
	Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");
	
	feedgps();
	
	gps.get_datetime(&date, &time, &age);
	Serial.print("Date(ddmmyy): "); Serial.print(date); Serial.print(" Time(hhmmsscc): "); Serial.print(time);
	Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");
	
	feedgps();
	
	gps.crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths, &age);
	Serial.print("Date: "); Serial.print(static_cast<int>(month)); Serial.print("/"); Serial.print(static_cast<int>(day)); Serial.print("/"); Serial.print(year);
	Serial.print("  Time: "); Serial.print(static_cast<int>(hour)); Serial.print(":"); Serial.print(static_cast<int>(minute)); Serial.print(":"); Serial.print(static_cast<int>(second)); Serial.print("."); Serial.print(static_cast<int>(hundredths));
	Serial.print("  Fix age: ");  Serial.print(age); Serial.println("ms.");
	
	feedgps();
	
	Serial.print("Alt(cm): "); Serial.print(gps.altitude()); Serial.print(" Course(10^-2 deg): "); Serial.print(gps.course()); Serial.print(" Speed(10^-2 knots): "); Serial.println(gps.speed());
	Serial.print("Alt(float): "); printFloat(gps.f_altitude()); Serial.print(" Course(float): "); printFloat(gps.f_course()); Serial.println();
	Serial.print("Speed(knots): "); printFloat(gps.f_speed_knots()); Serial.print(" (mph): ");  printFloat(gps.f_speed_mph());
	Serial.print(" (mps): "); printFloat(gps.f_speed_mps()); Serial.print(" (kmph): "); printFloat(gps.f_speed_kmph()); Serial.println();
	
	feedgps();
	
	gps.stats(&chars, &sentences, &failed);
	Serial.print("Stats: characters: "); Serial.print(chars); Serial.print(" sentences: "); Serial.print(sentences); Serial.print(" failed checksum: "); Serial.println(failed);
}
  
bool feedgps()
{
	while (nss.available())
	{
		if (gps.encode(nss.read()))
		return true;
	}

	return false;
}