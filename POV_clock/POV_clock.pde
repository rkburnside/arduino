// defining the alphabet
int A[] = {0,1,1,1,1,0,0, 1,0,1,0,0,0,0, 1,0,1,0,0,0,0, 0,1,1,0,0,0,0, 0,0,0,1,1,0,0};
int B[] = {1,1,1,1,1,0,0, 1,0,1,0,1,0,0, 1,0,1,0,1,0,0, 0,1,0,1,0,0,0, 0,0,0,0,0,0,0};
int C[] = {0,1,1,1,0,0,0, 1,1,0,1,1,0,0, 1,0,0,0,1,0,0, 0,0,0,0,1,0,0, 0,0,0,0,0,0,0};
int D[] = {1,1,1,1,1,0,0, 1,0,0,0,1,0,0, 1,0,0,0,1,0,0, 1,1,0,1,1,0,0, 0,1,1,1,0,0,0};
int E[] = {1,1,1,1,1,0,0, 1,0,1,0,1,0,0, 1,0,1,0,1,0,0, 0,0,1,0,1,0,0, 0,0,0,0,1,0,0};
int F[] = {1,1,1,1,1,0,0, 1,0,1,0,0,0,0, 1,0,1,0,0,0,0, 1,0,1,0,0,0,0, 1,0,0,0,0,0,0};
int G[] = {1,1,1,1,1,0,0, 1,0,0,0,1,0,0, 1,0,0,0,1,0,0, 1,0,1,0,1,0,0, 1,0,1,1,1,0,0};
int H[] = {1,1,1,1,1,0,0, 0,0,1,0,0,0,0, 0,0,1,0,0,0,0, 0,0,1,0,0,0,0, 1,1,1,1,1,0,0};
int I[] = {1,0,0,0,1,0,0, 1,0,0,0,1,0,0, 1,1,1,1,1,0,0, 1,0,0,0,1,0,0, 1,0,0,0,1,0,0};
int J[] = {1,0,0,1,1,0,0, 1,0,0,0,1,0,0, 1,1,1,1,1,0,0, 1,0,0,0,0,0,0, 1,0,0,0,0,0,0};
int K[] = {1,1,1,1,1,0,0, 0,0,1,0,0,0,0, 0,1,0,1,0,0,0, 0,1,0,1,0,0,0, 1,0,0,0,1,0,0};
int L[] = {1,1,1,1,1,0,0, 0,0,0,0,1,0,0, 0,0,0,0,1,0,0, 0,0,0,0,1,0,0, 0,0,0,0,1,0,0};
int M[] = {1,1,1,1,1,0,0, 0,1,0,0,0,0,0, 0,0,1,1,0,0,0, 0,1,0,0,0,0,0, 1,1,1,1,1,0,0};
int N[] = {1,1,1,1,1,0,0, 0,1,0,0,0,0,0, 0,0,1,0,0,0,0, 0,0,0,1,0,0,0, 1,1,1,1,1,0,0};
int O[] = {0,1,1,1,0,0,0, 1,0,0,0,1,0,0, 1,0,0,0,1,0,0, 1,0,0,0,1,0,0, 0,1,1,1,0,0,0};
int P[] = {1,1,1,1,1,0,0, 1,0,1,0,0,0,0, 1,0,1,0,0,0,0, 1,0,1,0,0,0,0, 0,1,0,0,0,0,0};
int Q[] = {0,1,1,1,0,0,0, 1,0,0,0,1,0,0, 1,0,1,0,1,0,0, 1,0,0,1,1,0,0, 0,1,1,1,1,0,0};
int R[] = {1,1,1,1,1,0,0, 1,0,1,0,0,0,0, 1,0,1,0,0,0,0, 1,0,1,1,0,0,0, 0,1,0,0,1,0,0};
int S[] = {0,1,0,0,1,0,0, 1,0,1,0,1,0,0, 1,0,1,0,1,0,0, 1,0,1,0,1,0,0, 0,0,0,1,0,0,0};
int T[] = {1,0,0,0,0,0,0, 1,0,0,0,0,0,0, 1,1,1,1,1,0,0, 1,0,0,0,0,0,0, 1,0,0,0,0,0,0};
int U[] = {1,1,1,1,0,0,0, 0,0,0,0,1,0,0, 0,0,0,0,1,0,0, 0,0,0,0,1,0,0, 1,1,1,1,0,0,0};
int V[] = {1,1,1,0,0,0,0, 0,0,0,1,0,0,0, 0,0,0,0,1,0,0, 0,0,0,1,0,0,0, 1,1,1,0,0,0,0};
int W[] = {1,1,1,1,1,0,0, 0,0,0,1,0,0,0, 0,0,1,0,0,0,0, 0,0,0,1,0,0,0, 1,1,1,1,1,0,0};
int X[] = {1,0,0,0,1,0,0, 0,1,0,1,0,0,0, 0,0,1,0,0,0,0, 0,1,0,1,0,0,0, 1,0,0,0,1,0,0};
int Y[] = {1,0,0,0,0,0,0, 0,1,0,0,0,0,0, 0,0,1,1,1,0,0, 0,1,0,0,0,0,0, 1,0,0,0,0,0,0};
int Z[] = {1,0,0,0,1,0,0, 1,0,0,1,1,0,0, 1,0,1,0,1,0,0, 1,1,0,0,1,0,0, 1,0,0,0,1,0,0};


int letterSpace = 1750;
int dotTime = 250;
int v = 0;

void setup()
{
	// initialize the digital pin as an output.
	pinMode(2, OUTPUT);     
	pinMode(3, OUTPUT);     
	pinMode(4, OUTPUT);     
	pinMode(5, OUTPUT);     
	pinMode(6, OUTPUT);     
	pinMode(7, OUTPUT);     
	pinMode(8, OUTPUT);     
	pinMode(9, OUTPUT);     
	pinMode(10, OUTPUT);     
	pinMode(11, INPUT);
}

void printLetter(int letter[])
{
	int y;

	// printing the first y row of the letter
	for (y=0; y<7; y++)
	{
		digitalWrite(y+3, letter[y]);
	}
	delayMicroseconds(dotTime);

	// printing the second y row of the letter
	for (y=0; y<7; y++)
	{
		digitalWrite(y+3, letter[y+7]);
	}
	delayMicroseconds(dotTime);

	// printing the third y row of the letter
	for (y=0; y<7; y++)
	{
		digitalWrite(y+3, letter[y+14]);
	}
	delayMicroseconds(dotTime);

	for (y=0; y<7; y++)
	{
		digitalWrite(y+3, letter[y+21]);
	}
	delayMicroseconds(dotTime);

	for (y=0; y<7; y++)
	{
		digitalWrite(y+3, letter[y+28]);
	}
	delayMicroseconds(dotTime);

	// printing the sspace between the letters
	for (y=0; y<7; y++)
	{
		digitalWrite(y+3, 0);
	}
	delayMicroseconds(letterSpace);
}

void loop()
{
if(v > 255) v = 0;

	if(digitalRead(11) == 0)
	{
		printLetter(A);
		printLetter(B);
		printLetter(C);
		printLetter(D);
		printLetter(E);
		printLetter(F);
		printLetter(G);
//		printLetter(H);
//		printLetter(I);
//		printLetter(J);
//		printLetter(K);
//		printLetter(L);
//		printLetter(M);
	}
/*
	if(digitalRead(11) == 0)
	{
		printLetter(N);
		printLetter(O);
		printLetter(P);
		printLetter(Q);
		printLetter(R);
		printLetter(S);
		printLetter(T);
		printLetter(U);
		printLetter(V);
		printLetter(W);
		printLetter(X);
		printLetter(Y);
		printLetter(Z);
	}
*/
}
