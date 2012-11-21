
// include the library code:
#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

int serIn;             // var that will hold the bytes-in read from the serialBuffer
char serInString[10]; // array that will hold the different bytes  10=10characters;


int  serInIndx  = 0;    // index of serInString[] in which to insert the next incoming byte
int  serOutIndx = 0;    // index of the outgoing serInString[] array;


void setup() {
  Serial.begin(9600);  //set serial to 9600 baud rate
  
  // set up the LCD's number of columns and rows: 
  lcd.begin(16, 2);
  lcd.clear();
  // Print a message to the LCD.
  lcd.print("hello, Helle!");
  

}

void loop() {
  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
  //lcd.setCursor(0, 1);
  // print the number of seconds since reset:
  //lcd.print(millis()/1000);
  
    lcd.setCursor(0, 0);
    lcd.print(millis()/1000);  
  
    int sb;   
    if(Serial.available()) { 
       //Serial.print("reading Serial String: ");     //optional confirmation
       String buffer = "";
       //lcd.setCursor(0, 1);
       //lcd.clear();
       //int i = 0;
       while (Serial.available()){          
          sb = Serial.read();
          buffer.concat(byte(sb));                   
          serInString[serInIndx] = sb;
          serInIndx++;
          delay(20);
          //i++;
        }
        lcd.setCursor(0, 1);
        lcd.print(buffer);
        delay(20);
    } else {
      /*
      Serial.flush();
      lcd.setCursor(0, 1);
      lcd.print("no signal");
      */
    }
    //lcd.clear();
}

void switchLed() {

}

