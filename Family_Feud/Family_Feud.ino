// family feud - first to press button and the servo sweeps to that side

#include <Servo.h>

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

int pos_red = 140;    // variable to store the servo position
int pos_center = 95;    // variable to store the servo position
int pos_white = 50;    // variable to store the servo position
int contestant_red_pin = 2;
int contestant_white_pin = 3;
const byte ledPin = 13;
volatile byte state = LOW;


void setup() {
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo.write(pos_center);

  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);

  pinMode(contestant_red_pin, INPUT_PULLUP);
  pinMode(contestant_white_pin, INPUT_PULLUP);
}

void loop() {
  if(digitalRead(contestant_red_pin) == LOW) contestant_red();
  if(digitalRead(contestant_white_pin) == LOW) contestant_white();
}

void contestant_red() {
  myservo.write(pos_red);              // tell servo to go to position in variable 'pos'
  blink();
  while(1) {}
}

void contestant_white() {
  myservo.write(pos_white);              // tell servo to go to position in variable 'pos'
  blink();
  while(1) {}
}

void blink() {
  state = !state;
  digitalWrite(ledPin, state);
}
