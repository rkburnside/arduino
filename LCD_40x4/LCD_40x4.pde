/*
  LiquidCrystal Library - Hello World
 
 Demonstrates the use a 16x2 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 This sketch prints "Hello World!" to the LCD
 and shows the time.
 
  The circuit:
 * 10K resistor:
 * ends to +5V and ground
 * wiper to LCD VO pin
 * lcd(RS, ENABLE, D4, D5, D6, D7)

 */

// include the library code:
#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(28, 26, 25, 24, 23, 22);
LiquidCrystal lcd2(28, 27, 25, 24, 23, 22);

void setup() {
  // set up the LCD's number of rows and columns: 
  lcd.begin(40, 2);
  lcd2.begin(40, 2);
  lcd.clear();
  lcd2.clear();
lcd.setCursor(0, 0); // top left
lcd.print("40X4 LCD DISPLAY.  BLACK DOTS ON GREEN  BACKGROUND.");
lcd2.setCursor(0, 0); // top left
lcd2.print("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:;'<>?,./ABC");
  }

void loop() {
  // Print a message to the LCD.
}