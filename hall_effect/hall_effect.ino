// constants
const int hallPin = 2;	// the number of the hallsensor pin

// variables will change:
int hallState = 0;	// variable for reading the pushbutton status

void setup() {
	Serial.begin(115200);
	// initialize the pushbutton pin as an input:
	pinMode(hallPin, INPUT);
}

void loop(){
	// read the state of the pushbutton value:
	hallState = digitalRead(hallPin);

	if (hallState == HIGH )
		Serial.println("no mag");
	
	else
		Serial.println("mag detected");
		
	// delay(5);
}