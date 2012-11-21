//----------------------Arduino code-------------------------

int message = 0;     //  This will hold one byte of the serial message

int zone1LEDPin = 11;   //  What pin is the green LED connected to?
int zone2LEDPin = 12;   //  What pin is the green LED connected to?
int zone3LEDPin = 13;   //  What pin is the red LED connected to?
int zone4LEDPin = 10;   //  What pin is the red LED connected to?
int zone5LEDPin = 9;   //  What pin is the red LED connected to?

int zone1LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone2LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone3LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone4LED = 0;          //  The value/brightness of the LED, can be 0-255
int zone5LED = 0;          //  The value/brightness of the LED, can be 0-255

void setup() {  
  Serial.begin(9600);  //set serial to 9600 baud rate
}

void loop(){
  
   // get a command string form the serial port
 
    if (Serial.available() > 0) { //  Check if there is a new message
      message = Serial.read();    //  Put the serial input into the message

     if (message == 'K'){
       zone1LED = 255;
     }
     if (message == 'k'){  //  If a lowercase 01r is received...
       zone1LED = 0;         //  Set redLED to 0 (off)
     }
     if (message == 'L'){  //  If a capitol 02R is received...
       zone2LED = 255;       //  Set redLED to 255 (on)
     }
     if (message == 'l'){  //  If a lowercase 02r is received...
       zone2LED = 0;         //  Set redLED to 0 (off)
     } 
     if (message == 'M'){  //  If a capitol 03R is received...
       zone3LED = 255;       //  Set redLED to 255 (on)
     }
     if (message == 'm'){  //  If a lowercase 03r is received...
       zone3LED = 0;         //  Set redLED to 0 (off)
     }   
     if (message == 'N'){  //  If a capitol 03R is received...
       zone4LED = 255;       //  Set redLED to 255 (on)
     }
     if (message == 'n'){  //  If a lowercase 03r is received...
       zone4LED = 0;         //  Set redLED to 0 (off)
     } 
     if (message == 'O'){  //  If a capitol 03R is received...
       zone5LED = 255;       //  Set redLED to 255 (on)
     }
     if (message == 'o'){  //  If a lowercase 03r is received...
       zone5LED = 0;         //  Set redLED to 0 (off)
     }
   }   
  analogWrite(zone1LEDPin, zone1LED);  //  Write an analog value between 0-255
  analogWrite(zone2LEDPin, zone2LED);  //  Write an analog value between 0-255
  analogWrite(zone3LEDPin, zone3LED);  //  Write an analog value between 0-255
  analogWrite(zone4LEDPin, zone4LED);  //  Write an analog value between 0-255
  analogWrite(zone5LEDPin, zone5LED);  //  Write an analog value between 0-255
}

//----------------------------end Arduino code--------------------------------
