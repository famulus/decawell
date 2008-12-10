int outPins[] = { 6,7,8};
int val;
int incomingByte = 0;	// for incoming serial data

void setup() {
	Serial.begin(9600);

	for(int i = 0; i < 4; i++ ) {
		pinMode(outPins[i], OUTPUT);
	}
}

void loop() {
	if (Serial.available() > 0) {
	// read the incoming byte:
		incomingByte = Serial.read();
		incomingByte = incomingByte - '0'; 


// global power off/on
		if(incomingByte == 0){
			digitalWrite(8,HIGH);
		}
		if(incomingByte == 1){
			digitalWrite(8,LOW);
		}


//winder stepper motor

		if(incomingByte == 2){
			digitalWrite(6,HIGH);
			delay(2);
			digitalWrite(6,LOW);
		}
		if(incomingByte == 3){
			digitalWrite(7,HIGH);
		}
		if(incomingByte ==4){
			digitalWrite(7,LOW);
		}



//wire guide stepper motor

		if(incomingByte == 5){
			digitalWrite(9,HIGH);
			delay(2);
			digitalWrite(9,LOW);
		}
		if(incomingByte == 6){
			digitalWrite(10,HIGH);
		}
		if(incomingByte == 7){
			digitalWrite(10,LOW);
		}




		}}
