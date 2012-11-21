import oscP5.*;        //  Load OSC P5 library
import netP5.*;        //  Load net P5 library
import processing.serial.*;    //  Load serial library

Serial arduinoPort;     //  Set arduinoPort as serial connection
OscP5 oscP5;            //  Set oscP5 as OSC connection
NetAddress clientIPAddress;

int incomingPort = 8000;
int outgoingPort = 9000;
String ipAddress = "192.168.0.195";

int arraySize = 7;    //number of zones to control (+1)
int redLED = 0;        //  redLED lets us know if the LED is on or off

float [] ledIntensity = new float [arraySize];
int [] slavetoggle = new int [arraySize]; //this array will keep the state of the slave toggle

float resetValue = 0.5; //%

int [] procLED = new int [arraySize];    //  Array allows us to add more toggle buttons in TouchOSC
int [] ardLED = new int [arraySize]; //Array that holds values of LEDS on the Arduino

int [] RedValue = new int [arraySize];
int [] GreenValue = new int [arraySize];
int [] BlueValue = new int [arraySize];

//arrays with on and off messages
String [] onSwitch = {
  "AB", 
  "BC", 
  "CD", 
  "DE", 
  "EF", 
  "FG", 
  "GH"
};
String [] offSwitch = {
  "ab", 
  "bc", 
  "cd", 
  "de", 
  "ef", 
  "fg", 
  "gh"
};
/*
String [] onSwitch = {
  "ABfffffffff", 
  "BCfffffffff", 
  "CDfffffffff", 
  "DEfffffffff", 
  "EFfffffffff", 
  "FGfffffffff", 
  "GHfffffffff"
};
String [] offSwitch = {
  "ab000000000", 
  "bc000000000", 
  "cd000000000", 
  "de000000000", 
  "ef000000000", 
  "fg000000000", 
  "gh000000000"
};
*/

void setup() {
  size(100, 100);        // Processing screen size
  noStroke();            //  We don’t want an outline or Stroke on our graphics
  oscP5 = new OscP5(this, incomingPort);  // Start oscP5, listening for incoming messages at port 8000
  clientIPAddress = new NetAddress(ipAddress, outgoingPort);
  arduinoPort = new Serial(this, Serial.list()[2], 9600);    // Set arduino to 9600 baud

  switchAllZones(true);

  //set default master and slavetoggles
  resetMasterSlaveToggles();
  
  //tell client Processing is ready
  oscP5.send(new OscMessage("/vibrate"), clientIPAddress);
}

void oscEvent(OscMessage theOscMessage) {   //  This runs whenever there is a new OSC message
  String addr = theOscMessage.addrPattern();  //  Creates a string out of the OSC message
  println(addr);
  String controlName;

  controlName = "/1/multitoggle1";
  if (addr.indexOf("/1/multitoggle1") !=-1) {   // Filters out any toggle buttons
    int i = int((addr.charAt(controlName.length()+1) )) - 0x30;   // returns the ASCII number so convert into a real number by subtracting 0x30
    procLED[i-1]  = int(theOscMessage.get(0).floatValue());     //  Puts button value into led[i]
  }

  controlName = "/1/multifader1";
  if (addr.indexOf(controlName) !=-1) {   // Filters out any fader buttons
    int i = int((addr.charAt(controlName.length()+1) )) - 0x30;   // returns the ASCII number so convert into a real number by subtracting 0x30

      //read value of control
    float val = theOscMessage.get(0).floatValue();

    //ledIntensity[i] = val;

    //dim LED

    //set label
    OscMessage mes = new OscMessage("/1/faderlabel" + (i) + "/text");
    mes.add((int)(val * 100) + "%");
    oscP5.send(mes, clientIPAddress);
  }

  if (addr.indexOf("/1/masterOn") !=-1) {
    switchAllZones(true);
    for (int i = 0; i < arraySize; i++) {
      procLED[i]=1;
    }
  }

  if (addr.indexOf("/1/masterOff") !=-1) {
    switchAllZones(false);
    procLED = new int [arraySize];
  }

  if (addr.indexOf("/1/masterfader") !=-1) {
    //read value of control
    float val = theOscMessage.get(0).floatValue();

    //update label
    OscMessage mes = new OscMessage("/1/masterfaderlabel/text");
    mes.add((int)(val * 100) + "%");
    oscP5.send(mes, clientIPAddress);

    //update all faders, start with 1
    for (int i = 1 ; i < arraySize ; i++) {
      //update only faders that have the toggle on

      println(i + "--" + slavetoggle[i] + "------");

      if (slavetoggle[i] == 1) {
        updateFader(i, val);
      }
    }
  }

  if (addr.indexOf("/1/masterslavebutton") !=-1) {
    for (int i = 1; i < arraySize; i++) {
      OscMessage mes = new OscMessage("/1/slavemultitoggle/" + (i) + "/1");
      mes.add(1);
      oscP5.send(mes, clientIPAddress);
      slavetoggle[i] = 1;
    }
  }

  controlName = "/1/slavemultitoggle";
  if (addr.indexOf(controlName) !=-1) {
    //read value
    float val = theOscMessage.get(0).floatValue();
    int i = int((addr.charAt(controlName.length() + 1) ))  - 0x30;
    slavetoggle[i] = int(val);
  }

  if (addr.indexOf("/1/reset") !=-1) {   // Filters out master button button
    //reset GUI
    resetFaders();
    resetMasterSlaveToggles();
  }
}  

void updateFader(int i, float value) {
  //update fader
  OscMessage mes = new OscMessage("/1/multifader1/1/" + i);
  mes.add(value);
  oscP5.send(mes, clientIPAddress);

  //update faderlabels 
  mes = new OscMessage("/1/faderlabel" + i + "/text");
  mes.add((int)(value * 100) + "%");
  oscP5.send(mes, clientIPAddress);
}

void resetFaders() {
  //reset masterfader
  OscMessage mes = new OscMessage("/1/masterfader/");
  mes.add(resetValue);
  oscP5.send(mes, clientIPAddress);

  //reset masterfaderlabel
  mes = new OscMessage("/1/masterfaderlabel/text");
  mes.add((int)(resetValue * 100) + "%");
  oscP5.send(mes, clientIPAddress);

  //reset other faders
  for (int i = 1; i < arraySize; i++) {
    updateFader(i, resetValue);
  }
}

void switchAllZones(boolean allOn) { 
  /*
  OscMessage mes = new OscMessage("/1/toggle1/color");
   mes.add("green");
   oscP5.send(mes, clientIPAddress);
   */

  for (int i = 0; i < arraySize; i++) {
    //set value
    OscMessage mes = new OscMessage("/1/multitoggle1/" + (i) + "/1");
    mes.add(allOn);
    oscP5.send(mes, clientIPAddress);
    //delay(50);
  }

  oscP5.send(new OscMessage("/vibrate"), clientIPAddress);
}

void resetMasterSlaveToggles() {
  OscMessage mes = new OscMessage("/1/masterslavemultitoggle/1/1");  
  mes.add("1");
  oscP5.send(mes, clientIPAddress);

  for (int i = 1; i < arraySize; i++) {
    mes = new OscMessage("/1/slavemultitoggle/" + (i) + "/1");
    mes.add("1");
    oscP5.send(mes, clientIPAddress);
    slavetoggle[i] = 1;
  }
}

void draw() {
  updateLEDS();
  
  background(50);        // Sets the background to a dark grey, can be 0-255

  fill(redLED, 0, 0);            // Fill rectangle with redLED amount
  ellipse(50, 50, 50, 50);    // Created an ellipse at 50 pixels from the left...
  // 50 pixels from the top and a width of 50 and height of 50 pixels

}

void updateLEDS() {
  for (int i = 0; i < arraySize; i++) {
    String message = "";

    if (ardLED[i] != procLED[i]) {
      //synch value
      ardLED[i] = procLED[i];

      if (ardLED[i] == 1) {
        message = onSwitch[i];// + padNum(RedValue[i], 3) + padNum(GreenValue[i], 3) + padNum(BlueValue[i], 3));//read preset value from array
      } else {
        message = offSwitch[i];//read preset value from array
      }
      println(message);
      arduinoPort.write(message);
    }
    delay(50);//give Arduino some breathing space
  }
}

//padds any int with 0
String padNum(int i, int paddingSize) {
  //return "4848" + i;
  return "123";
}
