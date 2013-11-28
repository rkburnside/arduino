/***********************************
Created March 1 2010 by Pavlos Iliopoulos - techprolet.com
with code parts from
Davo@arduino:forum
Copyright 2010
Pavlos Iliopoulos
rott/techprolet

Compass pinout
---------------
Ground to gps

VCC (Power 3.3V)
Yellow
3V3

XCLR (ADC reset input - keep low when system in idle state)
Orange
Pin8

SDA (I2C data input/output)
Red
AnalogIn4//Analog 4=Digital 18

MCLK (Master Clock Input)
Brown
Pin9

SCLK (I2C clock input)
Black
AnalogIn5//Analog5=Digital19
76u
* XCLR is to reset the AD converter (active low). XCLR should be set to high only during AD conversion phase(reading D1,D2), at all other states, such as reading calibration factors, this pin should be kept low.

* The quality of the MCLK signal can significantly influence the current consumption of the pressure module. To obtain minimum current, remember to supply good quality MCLK signal

Compass address must be (guess) 0x60
*/
#include <math.h>
#include <Wire.h>
int xclr=8;
int mclck=9;
int compassAddress=B0110000;				// [0110xx0] [xx] is determined by factory programming, total 4 different addresses are available
int xParam,yParam;
int minX=0;
int maxX=0;
int minY=0;
int maxY=0;

const int midX=2041;
const int midY=2040;
//  const double north = 1.3743; 			//calibration according to compass
const double north = 1.5708; 				//calibration according to gps
double northFi,targetFi,fi;
double degreesCompass;
double x;
double y;




void setup()
{
	pinMode(xclr, OUTPUT);
	digitalWrite(xclr, LOW);
	pinMode(mclck, OUTPUT);
	digitalWrite(mclck, LOW);
	Serial.begin(9600);

	Wire.begin();							//give some time (who's in a hurry?)
	delay (20);
	Wire.beginTransmission(compassAddress);	//Send target (master)address
	Wire.send(0x00);						//Wake up call, send SET signal to set/reset coil
	Wire.send(0x02);
	Wire.endTransmission();					// wait for SET action to settle
	delay(10);
}

void loop()
{
	//Serial.println("===========");

	getCompassData();						//by rotating compass, we'll eventually get the extreme values for x and y
	calcRadians();

/*	if (xParam>maxX)
		maxX=xParam;
	else if (minX==0)
		minX=xParam;
	else if (xParam<minX)
		minX=xParam;

	if (yParam>maxY)
		maxY=yParam;
	else if (minY==0)
		minY=yParam;
	else if (yParam<minY)
		minY=yParam;
*/

	//North (real)  (x,y)=(2055,2129)

	/*
	Serial.print ("Current values:");
	Serial.print (xParam);
	Serial.print (",");
	Serial.println (yParam);
	Serial.print ("Extremes: x(");
	Serial.print (minX);
	Serial.print (",");
	Serial.print (maxX);
	Serial.print (") y(");
	Serial.print (minY);
	Serial.print (",");
	Serial.print (maxY);
	Serial.println (")");
	*/

	Serial.print ("{");
	Serial.print (xParam);
	Serial.print (",");
	Serial.print (yParam);
	Serial.print ("},");
	Serial.println();
	delay(50);
}

void getCompassData()
{
	byte rcvByte[4];
	Wire.beginTransmission(compassAddress);	//Send target (master)address
	Wire.send(0x00);						//Wake up call, request for data
	Wire.send(0x01);
	Wire.endTransmission();					//wait 5ms min for compass to acquire data
	delay(7);
	Wire.requestFrom(compassAddress, 4);
	
	for (int i=0;i<4;i++)
	{
		rcvByte[i]=0;
		rcvByte[i] = Wire.receive();
	}
	
	xParam = rcvByte[0] << 8;
	xParam = xParam | rcvByte[1];
	yParam = rcvByte[2] << 8;
	yParam = yParam | rcvByte[3];

/*
Serial.println (xParam,BIN);
Serial.println (yParam,BIN);

for (int i=0;i<4;i++)
{
	for (int n=0;n<8;n++)
	{
		Serial.print((rcvByte[i]>>n)&1);
    }
    Serial.print(" ");
}

Serial.println();
*/
}

void calcRadians()
{
	x = -(xParam-midX);
	y = (yParam-midY);
	northFi = -(atan2 (y,x)-north);
	degreesCompass= (northFi*180)/M_PI;
	if (degreesCompass<0)
		degreesCompass+=360;

/*
	targetFi = (atan2 ((targetLat-currLat),(targetLon-currLon)));
	fi=northFi+targetFi-(M_PI/2);
	if (fi<-M_PI)
		fi+=2*M_PI;
	else if (fi>M_PI)
		fi-=2*M_PI;
*/		

	Serial.print ("Compass: ");
	Serial.print (degreesCompass);

//	Serial.println();
//	positive values in rad are to the west
//	Serial.println(fi);
}