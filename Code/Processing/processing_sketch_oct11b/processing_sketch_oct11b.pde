//on Arduino: Firmata

import processing.serial.*;
import cc.arduino.*;
import oscP5.*;        //  Load OSC P5 library
import netP5.*;        //  Load net P5 library

Arduino arduino;
OscP5 oscP5;            //  Set oscP5 as OSC connection
NetAddress [] clientIPAddress;

int incomingPort = 8000;
int outgoingPort = 9000;
String [] ipAddress = {"192.168.0.181", "192.168.0.189"};

int arraySize = 6;    //number of zones to control //?(+1)

int [] ledIntensity = new int [arraySize];
int [] slavetoggle = new int [arraySize]; //this array will keep the state of the slave toggle

float resetValue = 0.5; //%
float masterfaderLevel = resetValue; //default value
float [] faderLevel = {
  resetValue, resetValue, resetValue, resetValue, resetValue, resetValue
};

int updateLEDDelay = 0;

int [] procLED = {
  0, 0, 0, 0, 0, 0
};

int[] zonePinMapping = {
  3, 5, 6, 9, 10, 11
};

void setup() {  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[2], 57600);

  for (int i = 0; i <= arraySize; i++)
    arduino.pinMode(i, Arduino.OUTPUT);

  oscP5 = new OscP5(this, incomingPort);  // Start oscP5, listening for incoming messages at port 8000
  
  println(oscP5.ip());
  
  clientIPAddress = new NetAddress [ipAddress.length];
  
  for (int i = 0; i < ipAddress.length; i++) {
    clientIPAddress[i] = new NetAddress(ipAddress[i], outgoingPort);
  } 

  switchAllZones(true);

  //set default master and slavetoggles
  resetMasterSlaveToggles();

  //tell client Processing is ready
  //oscP5.send(new OscMessage("/vibrate"), clientIPAddress);
  updateClients(new OscMessage("/vibrate"));
}

void draw() {
  updateLEDS();
}

void oscEvent(OscMessage theOscMessage) {   //  This runs whenever there is a new OSC message
  String addr = theOscMessage.addrPattern();  //  Creates a string out of the OSC message
  println(addr);
  String controlName;

  //MULTITOGGLE
  controlName = "/1/multitoggle1";
  if (addr.indexOf("/1/multitoggle1") !=-1) {   // Filters out any toggle buttons
    int i = int((addr.charAt(controlName.length()+1) )) - 0x30;   // returns the ASCII number so convert into a real number by subtracting 0x30
    procLED[i-1]  = int(theOscMessage.get(0).floatValue());     //  Puts button value into led[i]

    if (procLED[i - 1] == 0) {
      ledIntensity[i - 1] = 0;
      println("ja");
    } 
    else {
      println("nei");
      ledIntensity[i - 1] = int(faderLevel[i - 1] * 255);
    }
  }

  //MULTIFADER
  controlName = "/1/multifader1";
  if (addr.indexOf(controlName) !=-1) {   // Filters out any fader buttons
    int i = int((addr.charAt(controlName.length()+1) )) - 0x30;   // returns the ASCII number so convert into a real number by subtracting 0x30

      //read value of control
    faderLevel[i - 1] = theOscMessage.get(0).floatValue();
    //faderLevel[i - 1] = val;

    //dim LED, if toggle is 1
    if (procLED[i - 1] == 0) {
      ledIntensity[i - 1] = 0;
    } 
    else {
      ledIntensity[i - 1] = int(faderLevel[i - 1] * 255);
    }

    //if slave is on, switch it off
    slavetoggle[i - 1] = 0;
    OscMessage mes = new OscMessage("/1/slavemultitoggle/" + (i) + "/1");
    mes.add(0);
    //oscP5.send(mes, clientIPAddress);
    updateClients(mes);

    //set label
    mes = new OscMessage("/1/faderlabel" + (i) + "/text");
    mes.add((int)(faderLevel[i - 1] * 100) + "%");
//    oscP5.send(mes, clientIPAddress);
    updateClients(mes);

  }

  //MASTERON
  if (addr.indexOf("/1/masterOn") !=-1) {
    switchAllZones(true);
    for (int i = 0; i < arraySize; i++) {
      procLED[i] = 1;
      //println(masterfaderLevel);
      ledIntensity[i] = int(masterfaderLevel * 255);
    }
  }

  //MASTEROFF
  if (addr.indexOf("/1/masterOff") != -1) {
    switchAllZones(false);
    for (int i = 0; i < arraySize; i++) {
      procLED[i] = 0;
      ledIntensity[i] = 0;
    }
  }

  //MASTERFADER
  if (addr.indexOf("/1/masterfader") != -1) {
    //read value of control
    masterfaderLevel = theOscMessage.get(0).floatValue();

    //update label
    OscMessage mes = new OscMessage("/1/masterfaderlabel/text");
    mes.add((int)(masterfaderLevel * 100) + "%");
//    oscP5.send(mes, clientIPAddress);
        updateClients(mes);


    //update all faders, start with 1
    for (int i = 0 ; i < arraySize ; i++) {
      //update only faders that have the toggle on
      if (slavetoggle[i] == 1) {
        updateFader(i, masterfaderLevel);
      }
    }
  }

  //MASTERSLAVEBUTTON
  if (addr.indexOf("/1/masterslavebutton") != -1) {
    for (int i = 0; i < arraySize; i++) {
      OscMessage mes = new OscMessage("/1/slavemultitoggle/" + (i + 1) + "/1");
      mes.add(1);
//      oscP5.send(mes, clientIPAddress);
          updateClients(mes);

      slavetoggle[i] = 1;
    }


    //set all faders to level of masterfader
    for (int i = 0; i < arraySize; i++) {
      updateFader(i, masterfaderLevel);
    }
  }

  //SLAVEMULTITOGGLE
  controlName = "/1/slavemultitoggle";
  if (addr.indexOf(controlName) !=-1) {
    //read value
    float val = theOscMessage.get(0).floatValue();
    int i = int((addr.charAt(controlName.length() + 1) ))  - 0x30;
    slavetoggle[i - 1] = int(val);
  }

  //RESET
  if (addr.indexOf("/1/reset") !=-1) {   // Filters out master button button
    //reset GUI
    masterfaderLevel = resetValue;
    resetFaders();
    resetMasterSlaveToggles();
  }
}  

/*
*
 */
void updateFader(int i, float value) {
  //update fader
  println("updatefader" + i);
  OscMessage mes = new OscMessage("/1/multifader1/1/" + (i + 1));
  mes.add(value);
//  oscP5.send(mes, clientIPAddress);
    updateClients(mes);

  //fade zone
  ledIntensity[i] = int(value * 255);

  //update faderlabels 
  mes = new OscMessage("/1/faderlabel" + (i + 1) + "/text");
  mes.add((int)(value * 100) + "%");
//  oscP5.send(mes, clientIPAddress);
    updateClients(mes);

}

/*
*
 */
void resetFaders() {
  //reset masterfader
  OscMessage mes = new OscMessage("/1/masterfader/");
  mes.add(resetValue);
//  oscP5.send(mes, clientIPAddress);
    updateClients(mes);

  //reset masterfaderlabel
  mes = new OscMessage("/1/masterfaderlabel/text");
  mes.add((int)(resetValue * 100) + "%");
  //oscP5.send(mes, clientIPAddress);
    updateClients(mes);

  //reset other faders
  for (int i = 0; i < arraySize; i++) {
    updateFader(i, resetValue);
  }
}

/*
*
 */
void switchAllZones(boolean allOn) { 
  for (int i = 0; i < arraySize; i++) {
    OscMessage mes = new OscMessage("/1/multitoggle1/" + (i + 1) + "/1");
    mes.add(allOn);
//    oscP5.send(mes, clientIPAddress);
      updateClients(mes);

  }

  if (allOn) {
    for (int i = 0; i < arraySize; i++) {
      procLED[i] = 1;
    }
  } 
  else {
    for (int i = 0; i < arraySize; i++) {
      procLED[i] = 0;
    }
  }

//  oscP5.send(new OscMessage("/vibrate"), clientIPAddress);
      updateClients(new OscMessage("/vibrate"));

}

/*
*
 */
void resetMasterSlaveToggles() {
  OscMessage mes = new OscMessage("/1/masterslavemultitoggle/1/1");  
  mes.add("1");
  //oscP5.send(mes, clientIPAddress);
  updateClients(mes);

  for (int i = 0; i < arraySize; i++) {
    mes = new OscMessage("/1/slavemultitoggle/" + (i + 1) + "/1");
    mes.add("1");
    //oscP5.send(mes, clientIPAddress);
    updateClients(mes);
    slavetoggle[i] = 1;
  }
}

/*
*
 */
void updateLEDS() {
  for (int i = 0; i < arraySize; i++) {
    if (procLED[1] == 1) {
      arduino.analogWrite(zonePinMapping[i], ledIntensity[i]);
    } 
    else {
      arduino.analogWrite(zonePinMapping[i], 0);
    }
    delay(updateLEDDelay);
  }
}

void updateClients(OscMessage mes) {

  for (int i = 0; i < clientIPAddress.length; i++) {
    oscP5.send(mes, clientIPAddress[i]);
  }
  
  
}

