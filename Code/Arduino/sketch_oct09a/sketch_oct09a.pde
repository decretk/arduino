int arraySize = 6;
int zoneLEDPins[] = {11,12,6,10,9,0};
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
  readSerialString();
  message = getSerialString();
  
  if (message.length() == 0){ 
    zoneLED[0] = 255;
  } else {
    zoneLED[0] = 0;
  }
  if (message.length() == 1){
    zoneLED[1] = 255;
  } else {
    zoneLED[1] = 0;
  } 
  if (message.length() == 2){ 
    zoneLED[2] = 255;
  } else {
    zoneLED[2] = 0;
  }   
   if (message.length() == 3){ 
    zoneLED[3] = 255;
  } else {
    zoneLED[3] = 0;
  }  

  if (message == '0'){
    zoneLED[4] = 255;
  }
 
  if (message == 'o'){
    zoneLED[4] = 0;
  }
 
  for (int i = 0; i < arraySize; i++) {
    analogWrite(zoneLEDPins[i], zoneLED[i]);  //  Write an analog value between 0-255
  }
//  delay(100);
}

//read a string from the serial and store it in an array
//this func uses globally set variable so it's not so reusable
//I need to find the right syntax to be able to pass to the function 2 parameters:
// the stringArray and (eventually) the index count
void readSerialString () {
    int sb;   
    if(Serial.available()) { 
       //Serial.print("reading Serial String: ");     //optional confirmation
       while (Serial.available()){ 
          sb = Serial.read();             
          serInString[serInIndx] = sb;
          serInIndx++;
        }
    }  
}

//print the string all in one time
//this func as well uses global variables
String getSerialString() {
  String out = "";
   if( serInIndx > 0) {
      Serial.print("Arduino memorized that you said: ");     
      //loop through all bytes in the array and print them out
      for(serOutIndx=0; serOutIndx < serInIndx; serOutIndx++) {
          out.concat(serInString[serOutIndx]);
      }
      
      //reset all the functions to be able to fill the string back with content
      serOutIndx = 0;
      serInIndx  = 0;
   }
  return out;
}
