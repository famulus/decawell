#define stepPin 8
#define dirPin 9
#define spool_stepPin 8
#define spool_dirPin 9

void setup()
{
  Serial.begin(9600);
  Serial.println("Starting stepper exerciser.");

  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);

  digitalWrite(dirPin, HIGH);
  digitalWrite(stepPin, LOW);

  pinMode(spool_stepPin, OUTPUT);
  pinMode(spool_dirPin, OUTPUT);

  digitalWrite(spool_dirPin, HIGH);
  digitalWrite(spool_stepPin, LOW);
}

void loop()
{
	 int i, j;
	Serial.print("Speed: ");
	Serial.println(1650);
	
	for (j=0; j<2000; j++)
	{
		digitalWrite(stepPin, HIGH);
		delayMicroseconds(2);
		digitalWrite(stepPin, LOW);
		delayMicroseconds(i);
		digitalWrite(spool_stepPin, HIGH);
		delayMicroseconds(2);
		digitalWrite(spool_stepPin, LOW);
		delayMicroseconds(i);
	}

	
  //   int i, j;
  //   
  //   for (i=1650; i>=600; i-=150)
  //   {
  //     Serial.print("Speed: ");
  //     Serial.println(i);
  //     
  //     for (j=0; j<2000; j++)
  //     {
  //       digitalWrite(stepPin, HIGH);
  //       delayMicroseconds(2);
  //       digitalWrite(stepPin, LOW);
  //       delayMicroseconds(i);
  //     }
  // 
  //     delay(500);
  //     Serial.println("Switching directions.");
  //     digitalWrite(dirPin, !digitalRead(dirPin));
  // 
  //     for (j=0; j<2000; j++)
  //     {
  //       digitalWrite(stepPin, HIGH);
  //       delayMicroseconds(2);
  //       digitalWrite(stepPin, LOW);
  //       delayMicroseconds(i);
  //     }
  // 
  //     delay(1000);
  //     Serial.println("Switching directions."); 
  //     digitalWrite(dirPin, !digitalRead(dirPin));
  // }
}
