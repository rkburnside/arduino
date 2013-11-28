#include <TinyGPS.h>
#include <SoftwareSerial.h>

SoftwareSerial serial_gps(4,5); // RX, TX
SoftwareSerial serial_bluetooth(3,2); // RX, TX
TinyGPS gps;

void gpsdump(TinyGPS &gps);
bool feedgps();
//void printFloat(double f, int digits = 2);

void setup(){
	serial_gps.begin(9600);
	serial_bluetooth.begin(115200);
	serial_bluetooth.println("start receiving nmea data");
}

void loop(){	
	serial_gps.listen();
	bool newdata = false;
	unsigned long start = millis();
	
	// Every 5 seconds we print an update
	while (millis() - start < 1000)
	{
		if (feedgps())
		newdata = true;
	}

	if (newdata){
		serial_bluetooth.println("Acquired Data");
		serial_bluetooth.println("-------------");
		gpsdump(gps);
		serial_bluetooth.println("-------------");
		serial_bluetooth.println();
	}
}

void gpsdump(TinyGPS &gps)
{
	long lat, lon;
	unsigned long age, date, time, chars;
	unsigned short sentences, failed;

	gps.get_position(&lat, &lon, &age);
	// gps.get_datetime(&date, &time, &age);
	gps.stats(&chars, &sentences, &failed);

	serial_bluetooth.print("Lat/Long(10^-5 deg): "); serial_bluetooth.print(lat); serial_bluetooth.print(", "); serial_bluetooth.println(lon); 
	// serial_bluetooth.print("Date(ddmmyy): "); serial_bluetooth.print(date); serial_bluetooth.print(" Time(hhmmsscc): "); serial_bluetooth.println(time);
	// serial_bluetooth.print("Alt(cm): "); serial_bluetooth.println(gps.altitude());
	// serial_bluetooth.print("Course(10^-2 deg): "); serial_bluetooth.println(gps.course());
	// serial_bluetooth.print("Course(float): "); serial_bluetooth.println(gps.f_course());
	// serial_bluetooth.print("Speed (mph): ");  serial_bluetooth.println(gps.f_speed_mph());
	//	serial_bluetooth.print("Stats: characters: "); serial_bluetooth.print(chars);
	//	serial_bluetooth.print("Sentences: "); serial_bluetooth.println(sentences);
	serial_bluetooth.print("Failed checksum: "); serial_bluetooth.println(failed);

	serial_bluetooth.print("Lat/Long(10^-5 deg): "); serial_bluetooth.print(lat); serial_bluetooth.print(", "); serial_bluetooth.println(lon); 
	
}

bool feedgps()
{
	while (serial_gps.available())
	{
		if (gps.encode(serial_gps.read()))
		return true;
	}
	return false;
}
