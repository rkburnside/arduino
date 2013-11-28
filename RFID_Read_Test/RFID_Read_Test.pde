#define ENABLE 2
int received = 0, valid = 0;


void setup()
{
	pinMode(ENABLE, OUTPUT);
	digitalWrite(ENABLE, LOW);
	Serial.begin(2400);
	Serial.println("RFID Tag Read Test");
	Serial.println("------------------");
}


void loop()
{
	if(Serial.available() > 0 )
	{
		if ((received = Serial.read()) != 0x0D)
			Serial.print("valid string received:\t");
		
		received = Serial.read();
				
		while (received != 0x0D)
		{
			if(received == -1)
			{
				Serial.println("\tinvalid string received");
				break;
			}
			
			Serial.print(received);
			received = Serial.read();
		}

		Serial.println();
		digitalWrite(ENABLE, HIGH);
		delay(1500);
	}

	digitalWrite(ENABLE, LOW);
}