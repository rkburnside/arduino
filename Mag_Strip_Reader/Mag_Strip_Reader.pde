/*
 * Magnetic Stripe Reader
 * by Stephan King http://www.kingsdesign.com
 *
 * Reads a magnetic stripe
 *
 */
 
int cld1Pin = 5;            // Card status pin
int rdtPin = 2;             // Data pin
int reading = 0;            // Reading status
volatile int buffer[400];   // Buffer for data
volatile int i = 0;         // Buffer counter
volatile int bit = 0;       // global bit
char cardData[40];          // holds card info
int charCount = 0;          // counter for info
int DEBUG = 0;
 
void setup() {
  Serial.begin(9600); 
 
  // The interrupts are key to reliable
  // reading of the clock and data feed
  attachInterrupt(0, changeBit, CHANGE);
  attachInterrupt(1, writeBit, FALLING);
}
 
void loop(){
 
  // Active when card present
  while(digitalRead(cld1Pin) == LOW){
    reading = 1;
  }     
 
  // Active when read is complete
  // Reset the buffer
  if(reading == 1) {  
 
    if (DEBUG == 1) {
      printBuffer();
    }
 
    decode();
    reading = 0;
    i = 0;
 
    int l;
    for (l = 0; l < 40; l = l + 1) {
      cardData[l] = '\n';
    }
 
    charCount = 0;
  }
}
 
// Flips the global bit
void changeBit(){
  if (bit == 0) {
    bit = 1;
  } else {
    bit = 0;
  }
}
 
// Writes the bit to the buffer
void writeBit(){
  buffer[i] = bit;
  i++;
}
 
// prints the buffer
void printBuffer(){
  int j;
  for (j = 0; j < 200; j = j + 1) {
    Serial.println(buffer[j]);
  }
}
 
int getStartSentinal(){
  int j;
  int queue[5];
  int sentinal = 0;
 
  for (j = 0; j < 400; j = j + 1) {
    queue[4] = queue[3];
    queue[3] = queue[2];
    queue[2] = queue[1];
    queue[1] = queue[0];
    queue[0] = buffer[j];
 
    if (DEBUG == 1) {
      Serial.print(queue[0]);
      Serial.print(queue[1]);
      Serial.print(queue[2]);
      Serial.print(queue[3]);
      Serial.println(queue[4]);
    }
 
    if (queue[0] == 0 & queue[1] == 1 & queue[2] == 0 & queue[3] == 1 & queue[4] == 1) {
      sentinal = j - 4;
      break;
    }
  }
 
  if (DEBUG == 1) {
    Serial.print("sentinal:");
    Serial.println(sentinal);
    Serial.println("");
  }
 
  return sentinal;
}
 
void decode() {
  int sentinal = getStartSentinal();
  int j;
  int i = 0;
  int k = 0;
  int thisByte[5];
 
  for (j = sentinal; j < 400 - sentinal; j = j + 1) {
    thisByte[i] = buffer[j];
    i++;
    if (i % 5 == 0) {
      i = 0;
      if (thisByte[0] == 0 & thisByte[1] == 0 & thisByte[2] == 0 & thisByte[3] == 0 & thisByte[4] == 0) {
        break;
      }
      printMyByte(thisByte);
    }
  }
 
  Serial.print("Stripe_Data:");
  for (k = 0; k < charCount; k = k + 1) {
    Serial.print(cardData[k]);
  }
  Serial.println("");
 
}
 
void printMyByte(int thisByte[]) {
  int i;
  for (i = 0; i < 5; i = i + 1) {
    if (DEBUG == 1) {
      Serial.print(thisByte[i]);
    }
}
    if (DEBUG == 1) {
      Serial.print("\t");
      Serial.print(decodeByte(thisByte));
      Serial.println("");
    }
 
    cardData[charCount] = decodeByte(thisByte);
    charCount ++;
}
 
char decodeByte(int thisByte[]) {
    if (thisByte[0] == 0 & thisByte[1] == 0 & thisByte[2] == 0 & thisByte[3] == 0 & thisByte[4] == 1){
      return '0';
    }
    if (thisByte[0] == 1 & thisByte[1] == 0 & thisByte[2] == 0 & thisByte[3] == 0 & thisByte[4] == 0){
      return '1';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 1 & thisByte[2] == 0 & thisByte[3] == 0 & thisByte[4] == 0){
      return '2';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 1 & thisByte[2] == 0 & thisByte[3] == 0 & thisByte[4] == 1){
      return '3';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 0 & thisByte[2] == 1 & thisByte[3] == 0 & thisByte[4] == 0){
      return '4';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 0 & thisByte[2] == 1 & thisByte[3] == 0 & thisByte[4] == 1){
      return '5';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 1 & thisByte[2] == 1 & thisByte[3] == 0 & thisByte[4] == 1){
      return '6';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 1 & thisByte[2] == 1 & thisByte[3] == 0 & thisByte[4] == 0){
      return '7';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 0 & thisByte[2] == 0 & thisByte[3] == 1 & thisByte[4] == 0){
      return '8';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 0 & thisByte[2] == 0 & thisByte[3] == 1 & thisByte[4] == 1){
      return '9';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 1 & thisByte[2] == 0 & thisByte[3] == 1 & thisByte[4] == 1){
      return ':';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 1 & thisByte[2] == 0 & thisByte[3] == 1 & thisByte[4] == 0){
      return ';';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 0 & thisByte[2] == 1 & thisByte[3] == 1 & thisByte[4] == 1){
      return '<';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 0 & thisByte[2] == 1 & thisByte[3] == 1 & thisByte[4] == 0){
      return '=';
    }
 
    if (thisByte[0] == 0 & thisByte[1] == 1 & thisByte[2] == 1 & thisByte[3] == 1 & thisByte[4] == 0){
      return '>';
    }
 
    if (thisByte[0] == 1 & thisByte[1] == 1 & thisByte[2] == 1 & thisByte[3] == 1 & thisByte[4] == 1){
      return '?';
    }
}
