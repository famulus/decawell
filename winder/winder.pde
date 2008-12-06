#define stepPin 6
#define dirPin 7
#define winder_stepPin 8
#define winder_dirPin 9

void setup()
{
  Serial.begin(9600);
  Serial.println("Starting stepper exerciser.");

  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(winder_stepPin, OUTPUT);
  pinMode(winder_dirPin, OUTPUT);

  digitalWrite(winder_stepPin, HIGH);
  digitalWrite(stepPin, LOW);
  digitalWrite(winder_dirPin, LOW);
  digitalWrite(dirPin, HIGH);
}

void loop()
{
    int i, j;
    
 
      
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(2);
        digitalWrite(stepPin, LOW);
        delayMicroseconds(10000);
      // Serial.println("Switching directions."); 
      // digitalWrite(dirPin, !digitalRead(dirPin));
      //   delayMicroseconds(2);
      // 
      //   digitalWrite(winder_stepPin, HIGH);
      //   delayMicroseconds(2);
      //   digitalWrite(winder_stepPin, LOW);
		
		

      // delay(500);
      // Serial.println("Switching directions.");
      // digitalWrite(dirPin, !digitalRead(dirPin));
      // 
      // for (j=0; j<2000; j++)
      // {
      //   digitalWrite(stepPin, HIGH);
      //   delayMicroseconds(2);
      //   digitalWrite(stepPin, LOW);
      //   delayMicroseconds(i);
      // }
      // 
      // // delay(1000);
      // Serial.println("Switching directions."); 
      // digitalWrite(dirPin, !digitalRead(dirPin));
  
}
