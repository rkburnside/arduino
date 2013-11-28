/* Minuteman / Roadrunner competition code

Pin Assignments:

A0 - Analog input from gyro
A1 - analog input for temp, from gyro
A2 - nc
A3 - nc
A4 - nc
A5 - nc
D0 - RX
D1 - TX
D2 - nc (normally Ch1 in)
D3 - Steering input (connected to Ch2 in on board)
D4 - MUX enble input (input only. manual if low, auto if high)
D5 - Mode input (switched by Ch3)
D6 - nc
D7 - nc
D8 - nc
D9 - nc (internally connected to MUX 1)  **consider connecting to MUX 3
D10 - Steering contorl out (internally connected to MUX 2
D11 - ESC control out (connect to MUX 3)
D12 - LED status
D13 - LED status
*/

#include <Servo.h>
#include <EEPROM.h>
#include "AVC_2013.h"
#include "EEPROMAnything.h"

//these are used for setting and clearing bits in special control registers on ATmega
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

volatile boolean gyro_flag = false, cal_flag;
boolean manual, automatic, aux=false, running=false, first=true;
volatile long gyro_sum = 0, gyro_count = 0, gyro_null=0, angle=0, clicks = 0;
long angle_last, angle_target, proximity, steer_us, angle_diff, previous_proximity=10000;
double x_wp[WAYPOINT_COUNT], y_wp[WAYPOINT_COUNT];
double x=0, y=0;
int speed_cur=0, speed_new=0, speed_old=0, steer_limm = 300;
byte wpr_count=1, wpw_count=1;
const int InterruptPin = 2 ;		//intterupt on digital pin 2
Servo steering, esc;
long time=0;
long time_1 = 0;

struct position_structure{

/* Using structures to contain location information. Will record old position 
and new position. The actual structures will be position[0] and position[1], 
but will use pointers old_pos and new_pos to access them. This way we can simply
swap the pointers instead of copying entire structure from one to the other. Access
data in the structures as follows: old_pos->x or new_pos->time, etc. this is equivalent
to (*old_pos).x.*/

    int x;
    int y;
    //boolean last;
} waypoint;

void encoder_interrupt(){
    clicks++;
}

void navigate(){
	calculate_speed();
	cal_steer_lim();
	update_position();
//	print_coordinates();
	update_steering();
	update_waypoint();
	get_mode();
	if (automatic) steering.writeMicroseconds(steer_us);
	if (automatic) speed();
}

void calculate_speed(){
    speed_new = micros();
    speed_cur = speed_new - speed_old;
    speed_old = speed_new;
}

void cal_steer_lim(){
	steer_limm = (int)map(speed_cur, L1, L2, L3, L4);
	if (steer_limm > L4) steer_limm = L4;
}

void update_position(){
	//calculate position
	x += sin((angle + angle_last) * 3.14159/GYRO_CAL);
	y += cos((angle + angle_last) * 3.14159/GYRO_CAL);
	angle_last = angle;
	angle_target = atan2((x_wp[wpr_count] - x),(y_wp[wpr_count] - y)) * GYRO_CAL/2.0/3.14159;
	proximity = abs(x_wp[wpr_count]-x) + abs(y_wp[wpr_count]-y);
}

void update_steering(){
	//calculate and write angles for steering
	angle_diff = angle_target - angle;
	if (angle_diff < -GYRO_CAL/2) angle_diff += GYRO_CAL;   //if angle is less than 180 deg, then add 360 deg
	if (angle_diff > GYRO_CAL/2) angle_diff -= GYRO_CAL;	//if angle is greater than 180 deg, then subtract 360
	//now, we have an angle as -180 < angle_diff < 180. 
	steer_us = (float)angle_diff/GYRO_CAL*STEER_GAIN;
	if (steer_us < 0-steer_limm) steer_us = 0-steer_limm;
	if (steer_us > steer_limm) steer_us = steer_limm;
	steer_us += STEER_ADJUST;  //adjusts steering so that it will go in a straight line
}

void update_waypoint(){
	//waypoint acceptance and move to next waypoint
	if (proximity < WAYPOINT_ACCEPT){
		wpr_count++;
		Serial.print("read WP # ");
		Serial.print(wpr_count);
		Serial.print(": ");
		Serial.print(x_wp[wpr_count]);
		Serial.print(" , ");
		Serial.println(y_wp[wpr_count]);
		proximity = abs(x_wp[wpr_count]-x) + abs(y_wp[wpr_count]-y);
		previous_proximity = proximity;
	}
}

void print_coordinates(){	//print stuff to Serial
	if((millis()-time)>1000){
		Serial.print(x_wp[wpr_count]);
		Serial.print(" , ");
		Serial.print(y_wp[wpr_count]);
		Serial.print(x);
		Serial.print(" , ");
		Serial.println(y);
		time = millis();
	}
}

void speed(){
	running = true;			// make sure running is updated.

	if((previous_proximity - proximity) <= P1) esc.writeMicroseconds(S2); //allow car to line up with the next point
	else if(proximity < P2) esc.writeMicroseconds(S2); //ensure that a waypoint can be accepted
	else if(proximity >= P2 && proximity < P3){ //slow way down  50-200 works well, 50-300 is more conservative for higher speeds
		if (speed_cur < BREAKING_SPEED)  esc.writeMicroseconds(SB);  // less than 8000 means high speed, apply brakes
		else esc.writeMicroseconds(S3);  //once speed is low enough, resume normal slow-down
	}
	else if(proximity >= P3) esc.writeMicroseconds(S4); //go wide open 200 works well for me. 
}

ISR(ADC_vect){			//ADC interrupt
	
	gyro_sum += ADCL | (ADCH << 8);  //read and accumulate high and low bytes of adc
	gyro_count++;    			//iterate the counter

	if (gyro_count == GYRO_LIMIT){
		angle += (gyro_sum - gyro_null);
		if ((angle > GYRO_CAL) && (!cal_flag)) angle -= GYRO_CAL; //if we are calculating null, don't roll-over
		if ((angle < 0) && (!cal_flag)) angle += GYRO_CAL;
		gyro_sum = 0;
		gyro_count =0;
		gyro_flag = true;
	}
}  

void set_gyro_adc(){
    //ADMUX should default to 000, which selects internal reference.
    ADMUX = B0;   //completely reset the MUX. should be sampling only on A0, now
    sbi(ADMUX, REFS0);  //use internal ref, AVcc
    //this section sets the prescalar for the ADC. 111 = 128 = 9.6kSps, 011 = 64 = 19.2kSps, 101=38.4ksps
    //tests show sss = 19ksps, css = 38.4ksps, scs = 76.8ksps
    sbi(ADCSRA, ADPS0);
    sbi(ADCSRA, ADPS1);
    sbi(ADCSRA, ADPS2);

	sbi(ADCSRA, ADEN);	//Enable ADC
	sbi(ADCSRA, ADATE);	//Enable auto-triggering
	sbi(ADCSRA, ADIE);	//Enable ADC Interrupt
	sei();				//Enable Global Interrupts
	sbi(ADCSRA, ADSC);	//Start A2D Conversions

	delay(100);			//small delay to let ADC "warm up" (don't know if it's necessary)
}

void calculate_null(){
	Serial.println("CALCULATING NULL");

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
	Serial.print("Null: ");
	Serial.println(gyro_null);
	//while (true);
}

void calibrate_gyro(){
	Serial.println("calibrating gyro");
	set_gyro_adc();
	delay(5000);
	cal_flag = true;		//tell ADC ISR that we are calibrating,
	gyro_flag = false;		//this will be set, already, but need to begin on new cycle
	while (!gyro_flag) ;	//wait for start of new cycle
	angle = 0;				//reset the angle

	do{
		get_mode();
		Serial.println(angle);
		delay(20);
	} while (aux);			//keep summing unitil we turn the mode switch off. angle will  not roll-over
	cal_flag = false;		//stop calibration

	//should print angle here
	Serial.print("total angle is: ");
	Serial.println(angle);
	angle = 0;
	gyro_count = 0;
	while (true);
}

long get_temp(){
	double temp = 0;
    for (int i=0; i <= 500; i++){
   	 temp += analogRead(1);
    }
    return temp;
}

void stab_temp(){
	Serial.println("Temperature");
	Serial.println("Stabilizing...");
	delay(1000);
	while (true){
		Serial.println(get_temp());
		delay(200);
	}
}

void watch_angle(){
	// Serial.print("angle watch");
	set_gyro_adc();		//sets up free running ADC for gyro
	calculate_null();
	do{
		get_mode();
		Serial.println(angle*360.0/GYRO_CAL);
		delay(500);
	} while (manual);		//keep summing unitil we turn the mode switch off.
}

void get_mode(){
    if (!digitalRead(TMISO)){
		manual = true;
		automatic = false;
		aux = false;
    }
    else if (!digitalRead(MODE)){
		manual = false;
		automatic = false;
		aux = true;
    }
    else{
		manual = false;
		automatic = true;
		aux = false;
    }
}

void set_waypoint(){
	waypoint.x = x;
	waypoint.y = y;
	//waypoint.last = false
	EEPROM_writeAnything(wpw_count*WP_SIZE, waypoint);
	Serial.print("set WP # ");
	Serial.print(wpw_count);
	Serial.print(waypoint.x);
	Serial.print(" , ");
	Serial.print(waypoint.y);
	wpw_count++;
	while(aux) get_mode();
}    

void load_waypoints(){
	int temp = 1;
	Serial.println("LOADING POINTS");

	while (temp <= WAYPOINT_COUNT){
		EEPROM_readAnything(temp*WP_SIZE, waypoint);
		x_wp[temp] = waypoint.x;
		y_wp[temp] = waypoint.y;
		temp++;
	}

	delay(1500);
	Serial.println("ALL POINTS LOADED");
	delay(1500);
}

void read_waypoint(){
	EEPROM_readAnything(wpr_count*WP_SIZE, waypoint);
	// long temp = micros();
	//x_wp = waypoint.x;
	//y_wp = waypoint.y;
	//waypoint.last = false
	//EEPROM_writeAnything(wp_count*WP_SIZE, waypoint);
	//Serial.print("read WP # ");
	//Serial.print(wpr_count);
	//Serial.print(": ");
	//Serial.print(waypoint.x);
	//Serial.print(" , ");
	//Serial.print(waypoint.y);
	//wpr_count++;
	//Serial.println(micros() - temp);
}    

void eeprom_clear(){  //EEPROM Clear
	// write a 0 to all 512 bytes of the EEPROM
	for (int i = 0; i < 512; i++) EEPROM.write(i, 0);

	// turn the LED on when we're done
	Serial.println("EEPROM clear");
	delay(1500);
}

void import_waypoints(){
	eeprom_clear();

	int i=0, j=WAYPOINT_COUNT;
	WAYPOINTS_STRING    //edit this in header file to change waypoints
	
	while(i<j){
		waypoint.x = excel_waypoints[i][0];
		waypoint.y = excel_waypoints[i][1];
		EEPROM_writeAnything(wpw_count*WP_SIZE, waypoint);
		i++;
		wpw_count++;
	}
	display_waypoints();
	Serial.println("ALL POINTS IMPORTED");
	delay(1500);
}

void export_waypoints(){
	load_waypoints();
	
	for(int i=0; i<19; i++){
		EEPROM_readAnything(wpr_count*WP_SIZE, waypoint);
		Serial.print("waypoint #");
		Serial.print(wpr_count);
		Serial.print(": ");
		Serial.print(waypoint.x);
		Serial.print(" , ");
		Serial.println(waypoint.y);
		wpr_count++;
	}

	Serial.println("ALL POINTS EXPORTED");
	delay(1500);
	return;
}

void display_waypoints(){
	for (int i=1; i <= 6; i++){
		EEPROM_readAnything(i*WP_SIZE, waypoint);
		Serial.print(i);
		Serial.print(": ");
		Serial.print(waypoint.x);
		Serial.print(" , ");
		Serial.println(waypoint.y);
	}
}

void edit_waypoint(){
	int i = Serial.parseInt();
	EEPROM_readAnything(i*WP_SIZE, waypoint);
	Serial.println();
	Serial.print("x (");
	Serial.print(waypoint.x);
	Serial.print("): ");
	waypoint.x = Serial.parseInt();
	Serial.println();
	Serial.print("y (");
	Serial.print(waypoint.y);
	Serial.print("): ");
	waypoint.y = Serial.parseInt();
	Serial.println("");
	EEPROM_writeAnything(i*WP_SIZE, waypoint);
	EEPROM_readAnything(i*WP_SIZE, waypoint);
	Serial.print(i);
	Serial.print(". ");
	Serial.print(waypoint.x);
	Serial.print(" , ");
	Serial.println(waypoint.y);
}

void menu_choices(){
	Serial.println();
	Serial.println();
	Serial.println("Main Menu");
	Serial.println("----------");
	Serial.println("a = watch angle");
	Serial.println("c = clear EEPROM");
	Serial.println("d = display waypoints");
	Serial.println("e = edit waypoint");
	Serial.println("i = import waypoints");
	Serial.println("p = export waypoints");
	Serial.println("s = stabilize temperature");
	Serial.println("x = exit. start setup routine for the race");
	Serial.println();
	Serial.println();
	return ;
}

void main_menu(){
	int loop = 1;
	menu_choices();
	Serial.flush();
	while(loop == 1){
		if(Serial.available() > 0){
	 		switch (Serial.read()){
				case 'a':
					watch_angle();
					menu_choices();
					break;
				case 'c':
					eeprom_clear();
					menu_choices();
					break;
				case 'd':
					display_waypoints();
					menu_choices();
					break;
				case 'e':
					Serial.println("Edit wp #?");
					edit_waypoint();
					menu_choices();
					break;
				case 'i':
					import_waypoints();
					menu_choices();
					break;
				case 'p':
					export_waypoints();
					menu_choices();
					break;
				case 's':
					stab_temp();
					menu_choices();
					break;
				case 'x':
					Serial.println("Setting up for the race");
					loop = 0;
					break;
				default:
					Serial.println("invalid entry. try again.");
					menu_choices();
					break;
			}
		}
	}
}

void setup(){
	//Pin assignments:
	pinMode(TMISO, INPUT);
	pinMode(MODE, INPUT);
	Serial.begin(115200);	//set up the LCD's number of columns and rows:
	Serial.setTimeout(100000);
	Serial.println(CAR_NAME);		//Print a message to the LCD.
	Serial.println();
	main_menu();

	delay(1500);

	pinMode(InterruptPin, INPUT);	 
	attachInterrupt(0, encoder_interrupt, CHANGE);	//interrupt 0 is on digital pin 2

	load_waypoints();

	//verify that car is in manual mode prior to starting null calculation
	
	get_mode();
	if(manual == false) Serial.print("SET CAR TO MANUAL MODE!");
	while(manual == false) get_mode();
	delay(1000);
	Serial.println("Calibrating gyro...");
	delay(1000);
	set_gyro_adc();		//sets up free running ADC for gyro
	//calculate_null();

	steering.attach(10);
	steering.writeMicroseconds(STEER_ADJUST);

	esc.attach(11);
	esc.writeMicroseconds(S1);

	//initialize all the settings
	wpr_count = 1;		//set waypoint read counter to first waypoint
	x=0;
	y=0;
	angle=0;
	clicks = 0;
	first = true;
	Serial.println("Ready to Run!!!");
}

void loop(){
	long temp;
	
	/* in the main loop here, we should wait for thing to happen, then act on them. Watch clicks and wait for it to reach CLICK_MAX, then calculate position and such.*/
	get_mode();
	if (clicks >= CLICK_MAX){
		clicks = 0;
		navigate();
	}

	if (aux && DEBUG == 1) calibrate_gyro();
	if (aux && DEBUG == 2) watch_angle();
	
	if (automatic){	//this function makes the car be stationary when in manual waypoint setting mode
		if (!running){
			esc.write(S2);	//i changed this to S1 so the car is stationary?
			running = true;
		}
		if (first){
			angle = 0;
			first = false;
		}
	}
	
	if (manual){	//this function makes the car be stationary when in manual waypoint setting mode
		if (running){
			esc.write(S1);	//i changed this to S1 so the car is stationary?
			running = false;
		}
	}

	if (wpr_count >= WAYPOINT_COUNT){
		esc.writeMicroseconds(S1);
		while (true);
	}
	
	while (Serial.available()){
		if (Serial.read() == 'd'){
			Serial.print(x);
			Serial.print(" , ");
			Serial.println(y);
		}
	}

	if (aux && DEBUG == 0){
		temp = millis();
		while (aux) get_mode();
		temp = millis() - temp;
		if (temp > 500 && temp < 5000) set_waypoint();
		if (temp > 5000) read_waypoint();
	}
	
	if (aux && DEBUG == 3){
		temp = millis();
		while (aux) get_mode();
		read_waypoint();
	}
	
	if((millis() - time_1) > 1000){
		Serial.print("\t");
		Serial.print(x,1);
		Serial.print("\t");
		Serial.println(y,1);
		time_1 = millis();
	}
}