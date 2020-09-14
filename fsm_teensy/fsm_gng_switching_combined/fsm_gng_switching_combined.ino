// FSMteensy
// Adil Khan, Basel 2016
// This version uses binary format for digi out
// 20170819 uses digital bit for trial end instead of serial
// This uses analog out at pin 23 PWM
// 20191107 merged with USBcom

#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder.
Encoder myEnc(1, 0);// (0,1) or (1,0) depending on direction of wheel motion

int ledPin = 13;
int trialendPin = 12;
int rewardPin = 2;
int digioutPins[] = {
  2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
}; // 2 is rewd valve, least significant bit
const int Npins = 11;
int analogoutPin = 23; // for PWM of laser power
int runfsm = 0;
int spdRngHi;
int spdRngLo;
int trialnum = 0;
int lickThreshold;
int speedMonitorFlag;
int USBcomFlag;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  for (int thisPin = 0; thisPin < Npins; thisPin++) {
    pinMode(digioutPins[thisPin], OUTPUT);
  }
  pinMode(ledPin, OUTPUT);
  pinMode(analogoutPin, OUTPUT);
  Serial.setTimeout(10);
  analogWriteResolution(12);
  analogWriteFrequency(analogoutPin, 1000); // 1KHz PWM
}


void loop()
{
  // start of trial
  // Matlab should be sending 'A' constantly
  // read it, reply with 'B'
  // then Matlab will send nRows nCols and stm
  establishContact();
  while (!Serial.available()) ; // hang program until a byte is received
  int nRows   = Serial.parseInt();
  int nCols   = Serial.parseInt();
  int spdBin  = Serial.parseInt();
  spdRngHi = Serial.parseInt();
  spdRngLo = Serial.parseInt();
  lickThreshold = Serial.parseInt();
  speedMonitorFlag = Serial.parseInt();
  USBcomFlag = Serial.parseInt();
  // send a signal to say its received
  Serial.println('C');

  // now Matlab will send stm
  int stm[nRows][nCols];
  //Serial.println(nRows);

  for (int r = 0; r < nRows; r++) {
    for (int c = 0; c < nCols; c++) {
      while (!Serial.available()) ; // hang program until a byte is received
      stm[r][c] = Serial.parseInt();

    }
  }
  Serial.println('D');

  // now Matlab will send a '>' to signal end of transmission
  while (!Serial.available()) ; // hang program until a byte is received

  char endChar = Serial.read();
  Serial.flush();

  if (endChar != '>') {
    // error, start again
    runfsm = 0;
    Serial.println("Error1");
    //Serial.flush();
    while (Serial.available()) {
      int dump = Serial.read();//clear input buffer
    }
  }
  else {

    Serial.println("startingFSM");
    digitalWrite(trialendPin, LOW);
    runfsm = 1;

  }

  // ------Now you have the state matrix------
  // ------start the state machine------


  int state = 0; // remember zero indexing

  int spdok;
  int spd = 0;
  int spdBin2 = 5; //5ms resolution for AO
  int sflag = 0;
  int lick = 0;
  int stateJustChanged = 1;
  unsigned long StartTime = millis();
  unsigned long CurrentTime = millis();
  unsigned long spdPrevMillis = millis();
  unsigned long spdCurrMillis = millis();
  long oldPosition = myEnc.read();
  long newPosition;
  if (runfsm == 1) {
    trialnum = trialnum + 1;
  }
  String triallog;
  triallog.reserve(10000);
  triallog = "startTrialNumber_";
  triallog += trialnum; triallog += "__";

  // State machine
  while (runfsm != 0) {

    // Check speed every x ms without pausing
    spdCurrMillis = millis();
    if (spdCurrMillis - spdPrevMillis >= spdBin2) {
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd = (newPosition - oldPosition) * 62.83 / (4 * spdBin2);
      oldPosition = newPosition;
      analogWrite(A14, spd * 20 + 500);
      // The actual speed in cm/s will need to be back calculated from this
      // 12 bit means 4095 is 3.3V
      // 500 is 3.3*500/4095 V ~ .4V
      // 20 is 3.3*20/4095 V ~ .016V
      // speed in cm/s = (outputVoltage - .4)/.016
      sflag = sflag + 1;
      if (sflag >= spdBin / spdBin2 && speedMonitorFlag == 1) {
        if (USBcomFlag == 1) {
          Serial.println('S');
          Serial.println(spd);
          //Serial.println(analogRead(0));
          Serial.send_now();
          sflag = 0;
        }
      }


    }

    spdok = checkSpeed(spd);

    if (analogRead(0) > lickThreshold) {
      lick = 1;
    }
    else {
      lick = 0;
    }

    if (stateJustChanged == 1) {
      // send digiout
      // least significant bit is pin2, reward
      int dig = stm[state][5];
      if (USBcomFlag == 1) {
        Serial.println(dig);
      }
      for (int i = 0; i < Npins; i++) {
        int val = bitRead(dig, i);
        digitalWrite(digioutPins[i], val);
      }

      // send analog out for PWM of laser
      if (nCols == 7) {
        analogWrite(analogoutPin, stm[state][6]);
      }

      // send the new state to matlab
      //Serial.println('S');
      //Serial.println(state);
      //Serial.send_now();
      StartTime = millis();
      stateJustChanged = 0;
    }
    CurrentTime = millis();

    // Now go through the triggers

    if (spdok == 1 && state != stm[state][0]) { // speed in
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][0]; triallog += "__";
      state = stm[state][0];
      stateJustChanged = 1;

    }

    else if (spdok == 0 && state != stm[state][1]) { // speed out
      //triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][1]; triallog += "__";
      //Reset TrialLog if SpeedOut happens (prevent overflow)
      triallog = "startTrialNumber_";
      triallog += trialnum; triallog += "__";
      state = stm[state][1];
      stateJustChanged = 1;
    }

    else if (lick == 1 && state != stm[state][2]) { // lick
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][2]; triallog += "__";
      state = stm[state][2];
      stateJustChanged = 1;
    }

    else if ((CurrentTime - StartTime) >= stm[state][4] && state != stm[state][3]) { // Timeup
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][3]; triallog += "__";
      state = stm[state][3];
      stateJustChanged = 1;
    }

    if (state == 99) { // end the trial
      triallog += millis(); triallog += "_"; triallog += state; triallog += "_End";
      if (USBcomFlag == 1) {
        Serial.println('E');
      }
      digitalWrite(trialendPin, HIGH);
      Serial.println(triallog);
      runfsm = 0;
    }
    if (Serial.available() > 0) { // if user clicks stop
      char stopChar = Serial.read();
      if (stopChar == 'X') {
        runfsm = 0;
        triallog += "stopped";
        trialnum = 0;
        //int loglength = triallog.length();
        //Serial.println(loglength);
        Serial.println(triallog);
        //digitalWrite(ledPin, LOW);
        allPinsLow();
        if (nCols == 7) {
          analogWrite(analogoutPin,0);
        }

      }
    }


  } // end while (runfsm != 0){

}

// ---- Functions-----


void establishContact() {
  int madeContact = 0;
  unsigned long spdPrevMillis = millis();
  unsigned long spdCurrMillis = millis();
  long oldPosition = myEnc.read();
  long newPosition;
  int spdBin2 = 5; // bins for speed measurement
  int spd2;

  while (madeContact == 0) {
    /*digitalWrite(ledPin,HIGH);
      delay(500);
      digitalWrite(ledPin,LOW);
      delay(500); */
    //Serial.println('G');
    if (Serial.available() > 0)  {
      char recvd = Serial.read();

      if (recvd == 'T') { // Matlab asking for name of teensy file
        while (Serial.available()) {
          int dump = Serial.read(); //Clear input buffer
        }
        Serial.flush();
        Serial.println(F(__FILE__));
      }


      if (recvd == 'V') { // Toggle reward valve
        digitalWrite(rewardPin, HIGH);
      }
      if (recvd == 'W') { // Toggle reward valve
        digitalWrite(rewardPin, LOW);
      }

      if (recvd == 'A') {
        while (Serial.available()) {
          int dump = Serial.read(); //Clear input buffer
        }
        Serial.flush();
        Serial.println('B');
        //Serial.println(recvd);
        madeContact = 1;
      }
    }
    // Check speed every x ms without pausing
    spdCurrMillis = millis();
    if (spdCurrMillis - spdPrevMillis >= spdBin2) {
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd2 = (newPosition - oldPosition) * 62.83 / (4 * spdBin2);
      oldPosition = newPosition;
      analogWrite(A14, spd2 * 20 + 500);
      digitalWrite(ledPin, HIGH);
      delay(1);
      digitalWrite(ledPin, LOW);

    }
  }
}


int checkSpeed(int spd) {
  int sok;
  if (spd > spdRngLo && spd < spdRngHi) {
    sok = 1;
  }
  else {
    sok = 0;
  }
  return sok;
}

void allPinsLow() {
  for (int pin = 0; pin < Npins; pin++) {
    digitalWrite(digioutPins[pin], LOW);
  }
}
