// family feud - first to press button and the servo sweeps to that side

#include <Servo.h>

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

int pos_left = 180;    // variable to store the servo position
int pos_right = 0;    // variable to store the servo position
int contestant_left_pin = 2;
const byte ledPin = 13;
volatile byte state = LOW;


void setup() {
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo.write(90);

  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);

  pinMode(contestant_left_pin, INPUT_PULLUP);
}

void loop() {
  if(digitalRead(contestant_left_pin) == HIGH) contestant_left();
}

void contestant_left() {
  myservo.write(0);              // tell servo to go to position in variable 'pos'
  while(1) {}
}

// void blink() {
//   state = !state;
//   digitalWrite(ledPin, state);
// }
