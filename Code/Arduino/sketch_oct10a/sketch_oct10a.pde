int arraySize = 6;
int zoneLEDPins[] = {10,11,6,10,9,0};

int zoneLED[6];

int serIn;             // var that will hold the bytes-in read from the serialBuffer
char serInString[2]; // array that will hold the different bytes  10=10characters;

int  serInIndx  = 0;    // index of serInString[] in which to insert the next incoming byte
int  serOutIndx = 0;    // index of the outgoing serInString[] array;

String message;

void setup() {  
  Serial.begin(9600);  //set serial to 9600 baud rate
}
  
void loop(){
    
    message = "";
    int sb;   
    if(Serial.available()) { 
       //Serial.print("reading Serial String: ");     //optional confirmation
       
       //lcd.setCursor(0, 1);
       //lcd.clear();
       //int i = 0;
       while (Serial.available()){          
          sb = Serial.read();
          message.concat(byte(sb));                   
          serInString[serInIndx] = sb;
          serInIndx++;
          delay(25);//doesn't work without this delay
          //i++;
        }
        //lcd.setCursor(0, 1);
        //lcd.print(buffer);
        //delay(20);
    } else {
      /*
      Serial.flush();
      lcd.setCursor(0, 1);
      lcd.print("no signal");
      */
    }
  
  if (message == "AB"){ 
    zoneLED[0] = 255;
  } 
  if (message == "ab"){ 
    zoneLED[0] = 0;
  }
  if (message == "BC"){
    zoneLED[1] = 255;
  } 
  if (message == "bc"){ 
    zoneLED[1] = 0;
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
