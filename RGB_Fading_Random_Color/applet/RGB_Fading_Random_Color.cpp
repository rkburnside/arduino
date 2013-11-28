// Fading LED 
// by BARRAGAN <http://people.interaction-ivrea.it/h.barragan> 

#include "WProgram.h"
void setup();
void loop();
int value = 0;                            // variable to keep the actual value 
int green = 9;                      // light connected to digital pin 9   green
int blue = 10;
int red = 11;
int r_value = 0;
int g_value = 0;
int b_value = 0;
int time = 10;
int max = 15;
int min = 0;

 
void setup() 
{ 
  randomSeed(analogRead(0));
} 
 
void loop() 
{ 
  r_value = random(min, max);
  g_value = random(min, max);
  b_value = random(min, max);
  

  for(value = 0 ; value <= 255; value+=5) // fade in (from min to max) 
  { 
    analogWrite(red, r_value);           // sets the value (range from 0 to 255) 
    analogWrite(blue, b_value);           // sets the value (range from 0 to 255) 
    analogWrite(green, g_value);           // sets the value (range from 0 to 255) 
    delay(time);                            // waits for 30 milli seconds to see the dimming effect 
  } 

  for(value = 255; value >=0; value-=5)   // fade out (from max to min) 
  { 
    analogWrite(red, r_value);           // sets the value (range from 0 to 255) 
    analogWrite(blue, b_value);           // sets the value (range from 0 to 255) 
    analogWrite(green, g_value);           // sets the value (range from 0 to 255) 
    delay(time); 
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

