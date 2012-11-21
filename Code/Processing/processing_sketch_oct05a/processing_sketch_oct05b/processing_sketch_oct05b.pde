//-----------------Processing code-----------------

import oscP5.*;        //  Load OSC P5 library
import netP5.*;        //  Load net P5 library
import processing.serial.*;    //  Load serial library

Serial arduinoPort;     //  Set arduinoPort as serial connection
OscP5 oscP5;            //  Set oscP5 as OSC connection
NetAddress clientIPAddress;

int incomingPort = 8000;
int outgoingPort = 9000;
String ipAddress = "192.168.0.196";

int arraySize = 10;
int redLED = 0;        //  redLED lets us know if the LED is on or off
int [] led = new int [arraySize];    //  Array allows us to add more toggle buttons in TouchOSC
float [] ledIntensity = new float [arraySize];

void setup() {
  size(100,100);        // Processing screen size
  noStroke();            //  We don’t want an outline or Stroke on our graphics
  oscP5 = new OscP5(this, incomingPort);  // Start oscP5, listening for incoming messages at port 8000
  clientIPAddress = new NetAddress(ipAddress, outgoingPort);
  arduinoPort = new Serial(this, Serial.list()[2], 9600);    // Set arduino to 9600 baud
}

void oscEvent(OscMessage theOscMessage) {   //  This runs whenever there is a new OSC message

  String addr = theOscMessage.addrPattern();  //  Creates a string out of the OSC message
  println(addr);
      
    if(addr.indexOf("/1/toggle") !=-1){   // Filters out any toggle buttons
      int i = int((addr.charAt(9) )) - 0x30;   // returns the ASCII number so convert into a real number by subtracting 0x30
      led[i]  = int(theOscMessage.get(0).floatValue());     //  Puts button value into led[i]
    }
    
    if(addr.indexOf("/1/fader") !=-1){   // Filters out any fader buttons
          //read value of control
          float val = theOscMessage.get(0).floatValue();
          
          int i = int((addr.charAt(8) )) - 0x30;   // returns the ASCII number so convert into a real number by subtracting 0x30
          println(i);
          
          ledIntensity[i] = val;
          

          //dim LED
          
          //set label
          OscMessage mes = new OscMessage(addr + "label/text");
          mes.add((int)(val * 100) + "%");
          oscP5.send(mes, clientIPAddress);                    
    }
    
    if(addr.indexOf("/1/master") !=-1){   // Filters out master button button    
      println(int(theOscMessage.get(0).floatValue()));
      
      
      //only fire on button-press, ignore button-up
      if (int(theOscMessage.get(0).floatValue()) == 1) {
        if (anyZonesOn()) {
          //if any on, turn all off          
          led = new int [10];   
          updateAllZones(false);  
        } else {
          //if all off, turn all on
          for(int i = 0; i < led.length; i++) {
            led[i]=1;
          }
          updateAllZones(true);
        }
      }
      
      //todo, reset buttons on GUI
    }
    
    if(addr.indexOf("/1/reset") !=-1){   // Filters out master button button
      //reset GUI
    }
}

boolean anyZonesOn() {
    for(int i = 0; i < led.length; i++) {
    if(led[i] == 1) return true;
        //break;
    }
    return false;
}

void updateFaderLabel(String faderName) {
  
}

void updateAllZones(boolean allOn) {
  
  //oscP5.send(new OscMessage("/1"), clientIPAddress);
  
  /*
  OscMessage mes = new OscMessage("/1/toggle1/color");
  mes.add("green");
  oscP5.send(mes, clientIPAddress);
  */
  
  for(int i = 1; i < 6; i++) {
    OscMessage mes = new OscMessage("/1/toggle" + i + "/value");
    if (allOn) {
      mes.add("1");
    } else {
      mes.add("0");
    }
    oscP5.send(mes, clientIPAddress);
  }


  oscP5.send(new OscMessage("/vibrate"), clientIPAddress);
  //println("blah");
  
  arduinoPort.write("fFfF"); 
 
}



void draw() {
 background(50);        // Sets the background to a dark grey, can be 0-255

  if(led[1] == 0){        //  If led button 1 if off do....
    arduinoPort.write("k");    // Sends the character “r” to Arduino
    redLED = 0;        // Sets redLED color to 0, can be 0-255
  }
  if(led[1] == 1){        // If led button 1 is ON do...
    arduinoPort.write("K");    // Send the character “R” to Arduino
    redLED = 255;        // Sets redLED color to 255, can be 0-255
  }
  if(led[2] == 0){        //  If led button 1 if off do....
    arduinoPort.write("l");    // Sends the character “r” to Arduino
    redLED = 0;        // Sets redLED color to 0, can be 0-255
  }
  if(led[2] == 1){        // If led button 1 is ON do...
    arduinoPort.write("L");    // Send the character “R” to Arduino
    redLED = 255;        // Sets redLED color to 255, can be 0-255
  }
  if(led[3] == 0){        //  If led button 1 if off do....
    arduinoPort.write("m");    // Sends the character “r” to Arduino
    redLED = 0;        // Sets redLED color to 0, can be 0-255
  }
  if(led[3] == 1){        // If led button 1 is ON do...
    arduinoPort.write("M");    // Send the character “R” to Arduino
    redLED = 255;        // Sets redLED color to 255, can be 0-255
  }
    if(led[4] == 0){        //  If led button 1 if off do....
    arduinoPort.write("n");    // Sends the character “r” to Arduino
    redLED = 0;        // Sets redLED color to 0, can be 0-255
  }
  if(led[4] == 1){        // If led button 1 is ON do...
    arduinoPort.write("N");    // Send the character “R” to Arduino
    redLED = 255;        // Sets redLED color to 255, can be 0-255
  }
    if(led[5] == 0){        //  If led button 1 if off do....
    arduinoPort.write("o");    // Sends the character “r” to Arduino
    redLED = 0;        // Sets redLED color to 0, can be 0-255
  }
  if(led[5] == 1){        // If led button 1 is ON do...
    arduinoPort.write("O");    // Send the character “R” to Arduino
    redLED = 255;        // Sets redLED color to 255, can be 0-255
  }
  fill(redLED,0,0);            // Fill rectangle with redLED amount
  ellipse(50, 50, 50, 50);    // Created an ellipse at 50 pixels from the left...
                // 50 pixels from the top and a width of 50 and height of 50 pixels
}

//----------------------------------end processing code------------------------------------
