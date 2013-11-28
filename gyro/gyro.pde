//gyro verification test
//Pin assignment: A1 - analog input from gyro
#define GYRO_LIMIT 1000					// defines how many gyro samples are taken between angle calculations
#define GYRO_CAL 8712891				// original calibration number
//#define GYRO_CAL 8790685				// adjusted up calibration number
#define NULL_CYCLES 50


volatile boolean new_cycle = false, cal_flag = false;	//volatile is use for interrupts (ISR)
volatile long gyro_sum = 0, gyro_count = 0, gyro_null=0, angle=0;

void setup() {
	Serial.begin(115200);
	set_gyro_adc();						// sets up free running ADC for gyro
	Serial.println("gyro null calculation begin");
	calculate_null();
	Serial.println("gyro angle is: ");
}

void loop() {
	Serial.println(angle);
	delay(250);
}

//Gyro Functions
void set_gyro_adc() {
	ADMUX = B01000001;					//completely resets the MUX. should be sampling only on A1, set vref to internal
	ADCSRA = B11101111;					//set scaler, auto trigger, sampling, etc
	sei();
	Serial.println("gyro adc set");
	return;
}

ISR(ADC_vect) {        //ADC interrupt
	gyro_sum += ADCL | (ADCH << 8);
	gyro_count++;        //iterate the counter

	if (gyro_count == GYRO_LIMIT) {
		angle += (gyro_sum - gyro_null);
		if((angle > GYRO_CAL) && (!cal_flag)) 	angle -= GYRO_CAL; //if we are calculating null, don't roll-over
		if((angle < 0) && (!cal_flag))			angle += GYRO_CAL;
		gyro_sum = 0;
		gyro_count = 0;
		new_cycle = true;
	}
} 

void calculate_null() {				// only used once for cal of null...should be used at each waypoint
	cal_flag = true;
	new_cycle = false;				// this will be set, already, but need to begin on new cycle
	while (!new_cycle) ;			// wait for start of new cycle
	angle = 0;						// reset the angle. angle will act as accumulator for null calculation
	gyro_null = 0;					// make sure to not subract any nulls here
	for (int i=0; i <= NULL_CYCLES; i++) {
		while (!new_cycle);
		new_cycle = false;			// start another round
	}
	gyro_null = angle/NULL_CYCLES;			// calculate the null
	cal_flag = false;
	angle = 0;
	Serial.println("gyro null calculation complete");
	Serial.print("gyro null: ");
	Serial.println(gyro_null);
	return;
}