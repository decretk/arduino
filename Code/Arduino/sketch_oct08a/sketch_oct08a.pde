int zone1LEDPin = 11;   //  What pin is the green LED connected to?
int zone2LEDPin = 12;   //  What pin is the green LED connected to?
int zone3LEDPin = 6;   //  What pin is the red LED connected to?
int zone4LEDPin = 10;   //  What pin is the red LED connected to?
int zone5LEDPin = 9;   //  What pin is the red LED connected to?

//int zoneLed[5];
//int zoneLedPins[5];

int zone1LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone2LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone3LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone4LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone5LED = 0;          //  The value/brightness of the LED, can be 0-255
/*
char inData[20]; // Allocate some space for the string
 char inChar=-1; // Where to store the character read
 byte index = 0; // Index into array; where to store the character
 */
char serIn;             // var that will hold the bytes-in read from the serialBuffer
char serInString[10]; // array that will hold the different bytes  100=100characters;
// -> you must state how long the array will be else it won't work.
int serInIndx  = 0;    // index of serInString[] in which to inser the next incoming byte

String message = "";

void setup() {  
  Serial.begin(9600);  //set serial to 9600 baud rate
}

void loop(){
  //keep reading from serial untill there are bytes in the serial buffer
  while (Serial.available()){        
    serIn = Serial.read();	        //read Serial        
    //serInString[serInIndx] = serIn; //insert the byte you just read into the array at the specified index
    message = message + serIn;
    //serInIndx++;                    //update the new index
  }


/*
  //print out later in the loop the sentence only if it has actually been collected;
  if( serInIndx > 0) {
    message = "";
    //loop through all bytes in the array and print them out
    for(serOutIndx=0; serOutIndx < serInIndx; serOutIndx++) {
      
      //serInString[serOutIndx] = "";            //optional: flush out the content
       message = message + serInString[serOutIndx];
    }
    
    //reset all the functions to be able to fill the string back with content
    serOutIndx = 0;
    serInIndx = 0;
  }
*/
  for (int i = 0; i < serInIndx; i++) {
    //message = message + serInString[i];
  }

 
  if (message == 'K'){
    zone1LED = 255;
  }
  if (message == 'k'){
    zone1LED = 0;
  }
  if (message == 'L'){
    zone2LED = 255;
  }
  if (message == 'l'){
    zone2LED = 0;
  } 
  if (message == 'M'){
    zone3LED = 255;
  }
  if (message == 'm'){
    zone3LED = 0;
  }   
  if (message == 'N'){
    zone4LED = 255;
  }
  if (message == 'n'){
    zone4LED = 0;
  } 
  if (message.length() == 0){
    zone5LED = 255;
  }
  if (message.length() > 0){
    zone5LED = 0;
  }
  
  
  //reset
  message = "";

  analogWrite(zone1LEDPin, zone1LED);  //  Write an analog value between 0-255
  analogWrite(zone2LEDPin, zone2LED);  //  Write an analog value between 0-255
  analogWrite(zone3LEDPin, zone3LED);  //  Write an analog value between 0-255
  analogWrite(zone4LEDPin, zone4LED);  //  Write an analog value between 0-255
  analogWrite(zone5LEDPin, zone5LED);  //  Write an analog value between 0-255

  delay(100); // Wait 100 milliseconds for next reading
}

