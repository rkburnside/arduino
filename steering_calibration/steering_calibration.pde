#define RR

/* Minuteman / Roadrunner competition code

attempting to add multi-waypoint functionality

This is the final release of version 0.1. At this point the car
will steer to a pre-defined waypoint under manual throttle.

The goal of this release is to test the functionality of the
Encoder and gyro pair. I will have the car drive forward under
manual control, and the system will update the x,y position as
it goes.

Pin Assignments:

A0 - Analog input from gyro
A1 - analog input for temp, from gyro
A2 - nc
A3 - LCD  (RS?)
A4 - LCD  (enable?)
A5 - LCD
D0 - RX
D1 - TX
D2 - nc (normally Ch1 in)
D3 - Steering input (connected to Ch2 in on board)
D4 - MUX enble input (input only. manual if low, auto if high)
D5 - Mode input (switched by Ch3)
D6 - LCD
D7 - LCD
D8 - LCD
D9 - nc (internally connected to MUX 1)  **consider connecting to MUX 3
D10 - Steering contorl out (internally connected to MUX 2
D11 - ESC control out (connect to MUX 3)
D12 - LED status
D13 - LED status
*/

#if ARDUINO > 21
#error "Oops! We need Arduino 21 or earlier"
#endif

#include <LiquidCrystal.h>
#include <Servo.h>
#include <EEPROM.h>
#include "steering_calibration.h"

#define DEBUG 0				//debug state  1=cal gyro, 2=watch angle, 3=read waypoints
#define GYRO_LIMIT 1000		//defines how many gyro samples are taken between angle calculations
#define MODE 5				//digital pin for mode select
#define TMISO 4				//digital pin for autopilot enable/disable
#define CLICK_MAX 3			//in the main loop, watch clicks and wait for it to reach CLICK_MAX, then calculate position
#define SERVO_LIM 300		//limits the swing of the servo so it does not get overstressed
#define WP_SIZE 20 			//number of bytes for each waypoint

//these are used for setting and clearing bits in special control registers on ATmega
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

LiquidCrystal lcd(A3, A4, A5, 8, 7, 6);
volatile boolean gyro_flag = false, cal_flag;
boolean manual, automatic, aux=false;
volatile long gyro_sum = 0, gyro_count = 0, gyro_null=0, angle=0, clicks = 0;
long angle_last, angle_target, proximity, steer_us, angle_diff, speed, speed_old, speed_new;
double x_wp[10], y_wp[10];
double x=0, y=0;
int wpr_count=1, wpw_count=1, wp_total;
const int InterruptPin = 2 ;		//intterupt on digital pin 2
Servo steering, esc;


template <class T> int EEPROM_writeAnything(int ee, const T& value)
{
	const byte* p = (const byte*)(const void*)&value;
	int i;
	for (i = 0; i < sizeof(value); i++)
      EEPROM.write(ee++, *p++);
	return i;
}

template <class T> int EEPROM_readAnything(int ee, T& value)
{
	byte* p = (byte*)(void*)&value;
	int i;
	for (i = 0; i < sizeof(value); i++)
      *p++ = EEPROM.read(ee++);
	return i;
}

struct position_structure {

/* Using structures to contain location information. Will record old position 
and new position. The actual structures will be position[0] and position[1], 
but will use pointers old_pos and new_pos to access them. This way we can simply
swap the pointers instead of copying entire structure from one to the other. Access
data in the structures as follows: old_pos->x or new_pos->time, etc. this is equivalent
to (*old_pos).x.*/

    double x;
    double y;
    //boolean last;
} waypoint;

void encoder_interrupt() {
    clicks++;
}

void calculate_parameters() {
	speed_new = millis();
	speed = speed_old - speed_new;
	speed_old = speed_new;
	
	//calculate position
	x += sin((angle + angle_last) * 3.14159/GYRO_CAL);
	y += cos((angle + angle_last) * 3.14159/GYRO_CAL);
	angle_last = angle;
	angle_target = atan2((x_wp[wpr_count] - x),(y_wp[wpr_count] - y)) * GYRO_CAL/2.0/3.14159;
	proximity = abs(x_wp[wpr_count]-x) + abs(y_wp[wpr_count]-y);
	
	//print stuff to LCD
	lcd.clear();
	lcd.print(x);
	lcd.print(",");
	lcd.print(y);
	
	//calculate and write angles for steering
	angle_diff = angle_target - angle;
	if (angle_diff < -GYRO_CAL/2) angle_diff += GYRO_CAL;
	if (angle_diff > GYRO_CAL/2) angle_diff -= GYRO_CAL;

	steer_us = 0; //(float)angle_diff/GYRO_CAL*SERVO_LIM*4.0;
	steer_us += STEER_ADJUST;  //1407
	
	//waypoint acceptance and move to next waypoint
	if (proximity < WAYPOINT_ACCEPT) {
		wpr_count++;
		lcd.clear();
		lcd.print("read WP # ");
		lcd.print(wpr_count);
		lcd.setCursor(0, 1);
		lcd.print(x_wp[wpr_count]);
		lcd.print(" , ");
		lcd.print(y_wp[wpr_count]);
	}
	
	get_mode();
	if (automatic) steering.writeMicroseconds(steer_us);
}

ISR(ADC_vect) {			//ADC interrupt
	
	uint8_t high,low;	//I think uint8_t is the same as byte.
	gyro_sum += ADCL | (ADCH << 8);  //read and accumulate high and low bytes of adc
	gyro_count++;    			//iterate the counter

	if (gyro_count == GYRO_LIMIT) {
		angle += (gyro_sum - gyro_null);
		if ((angle > GYRO_CAL) && (!cal_flag)) angle -= GYRO_CAL; //if we are calculating null, don't roll-over
		if ((angle < 0) && (!cal_flag)) angle += GYRO_CAL;
		gyro_sum = 0;
		gyro_count =0;
		gyro_flag = true;
	}
}  

void calculate_null() {
	
	cal_flag = true;		//tell ADC ISR that we are calibrating,
	gyro_flag = false;		//this will be set, already, but need to begin on new cycle
	while (!gyro_flag) ;	//wait for start of new cycle
	angle = 0;				//reset the angle. angle will act as accumulator for null calculation
	gyro_null = 0;			//make sure to not subract any nulls here

	for (int i=0; i <= 50; i++){
		while (!gyro_flag);
		gyro_flag = false;	//start another round
	}
	
	gyro_null = angle/50;	//calculate the null
	cal_flag = false;		//stop calibration
	angle = 0;

	//should print null here
	lcd.clear();
	lcd.print("Null: ");
	lcd.print(gyro_null);
	//while (true);
}

void calibrate_gyro() {
	lcd.clear();
	lcd.print("calibrating gyro");
	lcd.setCursor(0, 1);
	set_gyro_adc();
	delay(5000);
	cal_flag = true;		//tell ADC ISR that we are calibrating,
	gyro_flag = false;		//this will be set, already, but need to begin on new cycle
	while (!gyro_flag) ;	//wait for start of new cycle
	angle = 0;				//reset the angle

	do {
		get_mode();
		lcd.clear();
		lcd.print(angle);
		delay(20);
	} while (aux);			//keep summing unitil we turn the mode switch off. angle will  not roll-over
	cal_flag = false;		//stop calibration

	//should print angle here
	lcd.clear();
	lcd.print("total angle is:");
	lcd.setCursor(0, 1);
	lcd.print(angle);
	angle = 0;
	gyro_count = 0;
	while (true);
}

long get_temp() {
	double temp = 0;
    for (int i=0; i <= 500; i++){
   	 temp += analogRead(1);
    }
    return temp;
}

void stab_temp() {
	lcd.clear();
	lcd.print("Temperature");
	lcd.setCursor(0, 1);
	lcd.print("Stabilizing...");
	delay(1000);
	while (true) {
		lcd.clear();
		lcd.print(get_temp());
		delay(200);
	}
}

void watch_angle() {
	lcd.clear();
	lcd.print("angle watch");
	do {
		get_mode();
		lcd.clear();
		lcd.print(angle*360.0/GYRO_CAL);
		delay(100);
	} while (aux);		//keep summing unitil we turn the mode switch off.
}

void get_mode() {
    if (!digitalRead(TMISO)) {
		manual = true;
		automatic = false;
		aux = false;
    }
    else if (!digitalRead(MODE)) {
		manual = false;
		automatic = false;
		aux = true;
    }
    else {
		manual = false;
		automatic = true;
		aux = false;
    }
}

void set_gyro_adc() {
	//ADMUX should default to 000, which selects internal reference.
	ADMUX = B0;   //completely reset the MUX. should be sampling only on A0, now
	ADMUX |= (1 << REFS0);		//use internal ref, AVcc
	//this section sets the prescalar for the ADC. 111 = 128 = 9.6kSps, 011 = 64 = 19.2kSps, 101=38.4ksps
	ADCSRA |= (1 << ADPS0);		//set prescale bit 0
	ADCSRA |= (1 << ADPS1);		//set prescale bit 1
	ADCSRA |= (1 << ADPS2);		//set prescale bit 2
	//maybe try this instead:
	//ADCSRA |= B111;   //sets the prescalar 111=128, 110=64, 101=32, 100=16

	ADCSRA |= (1 << ADEN);		//Enable ADC
	ADCSRA |= (1 << ADATE);		//Enable auto-triggering

	ADCSRA |= (1 << ADIE);		//Enable ADC Interrupt
	sei();						//Enable Global Interrupts
	ADCSRA |= (1 << ADSC);		//Start A2D Conversions
	delay(100);					//small delay to let ADC "warm up" (don't know if it's necessary)
}

void set_waypoint() {
	waypoint.x = x;
	waypoint.y = y;
	//waypoint.last = false
	EEPROM_writeAnything(wpw_count*WP_SIZE, waypoint);
	lcd.clear();
	lcd.print("set WP # ");
	lcd.print(wpw_count);
	lcd.setCursor(0, 1);
	lcd.print(waypoint.x);
	lcd.print(" , ");
	lcd.print(waypoint.y);
	wpw_count++;
	while(aux) get_mode();
}    

void load_waypoints() {
	int temp = 1;
	while (temp <= 10) {
		EEPROM_readAnything(temp*WP_SIZE, waypoint);
		x_wp[temp] = waypoint.x;
		y_wp[temp] = waypoint.y;
		temp++;
	}
}

void read_waypoint() {
	long temp = micros();
	EEPROM_readAnything(wpr_count*WP_SIZE, waypoint);
	//x_wp = waypoint.x;
	//y_wp = waypoint.y;
	//waypoint.last = false
	//EEPROM_writeAnything(wp_count*WP_SIZE, waypoint);
	lcd.clear();
	lcd.print("read WP # ");
	lcd.print(wpr_count);
	lcd.setCursor(0, 1);
	lcd.print(waypoint.x);
	lcd.print(" , ");
	lcd.print(waypoint.y);
	wpr_count++;
	lcd.clear();
	lcd.print(micros() - temp);
}    

//EEPROM Clear
void eeprom_clear() {
	// write a 0 to all 512 bytes of the EEPROM
	for (int i = 0; i < 512; i++) EEPROM.write(i, 0);

	// turn the LED on when we're done
	lcd.clear();
	lcd.print("EEPROM clear");
	digitalWrite(13, HIGH);
	delay(5000);
}

void import_waypoints() {
	int i=0;
	float from_excel[3][2] = {{0,600}, {600,600}, {0,0}};
	eeprom_clear();
	
	while(i<3) {
		waypoint.x = from_excel[i][0];
		waypoint.y = from_excel[i][1];
		EEPROM_writeAnything(wpw_count*WP_SIZE, waypoint);
		i++;
	}

	lcd.clear();
	lcd.print("all points imported");
	delay(1500);
}

void setup() {
	//Pin assignments:
	pinMode(TMISO, INPUT);
	pinMode(MODE, INPUT);
	lcd.begin(16, 2);			//set up the LCD's number of columns and rows:
	lcd.print(CAR_NAME);	//Print a message to the LCD.
	delay(1500);
	//stab_temp();			// uncomment to watch temperature stabilization
	pinMode(InterruptPin, INPUT);	 
	attachInterrupt(0, encoder_interrupt, CHANGE);	//interrupt 0 is on digital pin 2
	//print_here();
	get_mode();
	//read_waypoint();
	//get_mode();

	
	//import waypoints
//	import_waypoints();
/*	lcd.clear();
	lcd.print("IMPORT WAYPOINTS?");
	lcd.setCursor(0, 1);
	lcd.print("set aux @ +100")
*/
	load_waypoints();
	wpr_count = 1;

	set_gyro_adc();		//sets up free running ADC for gyro
	calculate_null();

	steering.attach(10);
	steering.writeMicroseconds(STEER_ADJUST);

	esc.attach(11);
	esc.writeMicroseconds(1503);

	wp_total = EEPROM.read(0);
	
}

void loop() {
	long temp;
	/* in the main loop here, we should wait for thing to happen, then act on them. Watch clicks and wait for it to reach CLICK_MAX, then calculate position and such.*/
	get_mode();
	if (clicks >= CLICK_MAX) {
		clicks = 0;
		calculate_parameters();
	}
	
	if (aux && DEBUG == 1) calibrate_gyro();
	if (aux && DEBUG == 2) watch_angle();
	
	if (aux && DEBUG == 0) {
		temp = millis();
		while (aux) get_mode();
		temp = millis() - temp;
		if (temp > 500 && temp < 2500) set_waypoint();
		if (temp >= 2500 && temp < 3500) read_waypoint();
		if (temp > 3500) eeprom_clear();
	}
	
	if (aux && DEBUG == 3) {
		temp = millis();
		while (aux) get_mode();
		read_waypoint();
	}
}
