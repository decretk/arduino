int message = 0;     //  This will hold one byte of the serial message

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

char inData[20]; // Allocate some space for the string
char inChar=-1; // Where to store the character read
byte index = 0; // Index into array; where to store the character

void setup() {  
  Serial.begin(9600);  //set serial to 9600 baud rate
}

void loop(){
     message = Serial.read();
     
  /*
     if (Comp("K") == 0) {
       zone1LED = 255;
     }
    */ 
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
     if (message == 'O'){
       zone5LED = 255;
     }
     if (message == 'o'){
       zone5LED = 0;
     }
  
  analogWrite(zone1LEDPin, zone1LED);  //  Write an analog value between 0-255
  analogWrite(zone2LEDPin, zone2LED);  //  Write an analog value between 0-255
  analogWrite(zone3LEDPin, zone3LED);  //  Write an analog value between 0-255
  analogWrite(zone4LEDPin, zone4LED);  //  Write an analog value between 0-255
  analogWrite(zone5LEDPin, zone5LED);  //  Write an analog value between 0-255
}

char Comp(char* This){
 while(Serial.available() > 0) // Don't read unless
   // there you know there is data
 {
   if(index < 19) // One less than the size of the array
   {
     inChar = Serial.read(); // Read a character
     inData[index] = inChar; // Store it
     index++; // Increment where to write next
     inData[index] = '\0'; // Null terminate the string
   }
 }

 if(strcmp(inData,This)  == 0){
   for(int i=0;i<19;i++){
     inData[i]=0;
   }
   index=0;
   return(0);
 }
 else{   
   return(1);
 }
}
