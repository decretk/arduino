int arraySize = 6;
int zoneLEDPins[] = {9,10,11,3,5,6};

int zoneLED[] = {0,0,0,0,0,0};

String serial = "";

void setup() {  
  Serial.begin(9600);  //set serial to 9600 baud rate
  startSequence();
}

void loop(){

  readSerial();
  

  if (serial == "AB"){ 
    zoneLED[0] = 255;
  } 
  if (serial == "ab"){ 
    
    zoneLED[0] = 0;
  }
  
  if (serial == "BC"){
    zoneLED[1] = 255;
  } 
  if (serial == "bc"){ 
    zoneLED[1] = 0;
  }
  
  if (serial == ""){
    zoneLED[2] = 255;
  } else {
    zoneLED[2] = 0;
  }
  
  /*  
   if (message == "ABfffffffff"){ 
   zoneLED[0] = 255;
   
   } 
   if (message == "ab000000000"){ 
   zoneLED[0] = 0;
   }
   if (message == "BCfffffffff"){
   zoneLED[1] = 255;
   } 

   if (message == "bc000000000"){ 
   zoneLED[1] = 0;
   }
   */
  for (int i = 0; i < arraySize; i++) {
    analogWrite(zoneLEDPins[i], zoneLED[i]);  //  Write an analog value between 0-255
  }
}


void readSerial() {
  int sb; 
 
  serial = "";//only if new signal is available, reset
  if(Serial.available()) {

    while (Serial.available()){          
      sb = Serial.read();
      //serial.concat(byte(sb));
      serial += byte(sb);    
      delay(25);//doesn't work without this delay
    }
    

  } 
  else {
    
  }
  Serial.println(serial);
      delay(500);
}

void startSequence() {
  for (int i = 0; i < arraySize; i++) {
    analogWrite(zoneLEDPins[i], 255);
  }

  delay(1000);
}

