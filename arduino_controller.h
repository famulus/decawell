int outPins[] = { 
  6,7,8,12,13};
int val;
int incomingByte = 0;	// for incoming serial data

void setup() {
  Serial.begin(9600);

  for(int i = 0; i < 5; i++ ) {
    pinMode(outPins[i], OUTPUT);
  }

  digitalWrite(8,LOW); // turn motors off by default
}



void loop() {
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();
    incomingByte = incomingByte - '0'; 

    Serial.println(incomingByte);
    // global power off/on
    if(incomingByte == 0){
      digitalWrite(8,LOW);
    }
    if(incomingByte == 1){
      digitalWrite(8,HIGH);
    }


    //winder stepper motor

    if(incomingByte == 2){
      digitalWrite(6,HIGH);
      delay(2);
      digitalWrite(6,LOW);
      delay(2);
    }
    if(incomingByte == 3){
      digitalWrite(7,HIGH);
    }
    if(incomingByte ==4){
      digitalWrite(7,LOW);
    }



    //wire guide stepper motor

    if(incomingByte == 5){
      digitalWrite(12,HIGH);
      delay(2);
      digitalWrite(12,LOW);
      delay(2);
    }
    if(incomingByte == 6){
      digitalWrite(13,HIGH);
    }
    if(incomingByte == 7){
      digitalWrite(13,LOW);
    }




  }
}
