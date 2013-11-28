//this is a simple sketch for MUX_SWITCHing the arduino between manual and autonomous modes wirelessly. if channel 3 reads less than 1600-ms (i.e. low), the car will be in manual mode. if channel 3 reads greater than 1600-ms (i.e. high), the car will be in autonomous mode.

#define CH3 10			//pin # for receiver CH3 IN
#define MUX_SWITCH 11	//pin # for MUX_SWITCHing MUX
#define LED_PIN 13		//pin # for the LED

void setup(){
	pinMode(CH3, INPUT);
	pinMode(MUX_SWITCH, OUTPUT);
	pinMode(LED_PIN, OUTPUT);
}

void loop(){
	int pulse_length;

	pulse_length = pulseIn(CH3, HIGH, 20000);

	if(pulse_length < 1600){
		digitalWrite(MUX_SWITCH, LOW);
		digitalWrite(LED_PIN, LOW);
	}
	
	else {
	digitalWrite(MUX_SWITCH, HIGH);
	digitalWrite(LED_PIN, HIGH);
	}
	
	return;
}