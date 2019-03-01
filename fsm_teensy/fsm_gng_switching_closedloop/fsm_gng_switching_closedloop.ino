
#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder.
Encoder myEnc(1, 0);// (0,1) or (1,0) depending on direction of wheel motion

int ledPin = 13;
int digioutPins[] = {
  2, 3, 4, 5, 6, 7, 8, 9, 10
}; // 2 is rewd valve, rest are visual stim related
int runfsm = 0;
int spdRngHi;
int spdRngLo;
int trialnum = 0;
int lickThreshold;
const int Npins = 9;
int USBcomFlag;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  for (int thisPin = 0; thisPin < Npins; thisPin++) {
    pinMode(digioutPins[thisPin], OUTPUT);
  }
  pinMode(ledPin, OUTPUT);
  Serial.setTimeout(10);
  analogWriteResolution(12);
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
    runfsm = 1;

  }

  // ------Now you have the state matrix------
  // ------start the state machine------


  int state = 0; // remember zero indexing

  int spdok;
  int spd = 0;
  int lick = 0;
  int stateJustChanged = 1;
  unsigned long StartTime = millis();
  unsigned long CurrentTime = millis();
  unsigned long spdPrevMillis = millis();
  unsigned long spdCurrMillis = millis();
  long oldPosition = myEnc.read();
  long StartPosition = myEnc.read();
  long CurrentPosition = myEnc.read();
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
    if (spdCurrMillis - spdPrevMillis >= spdBin) {
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd = (newPosition - oldPosition) * 62.83 / (4 * spdBin);
      oldPosition = newPosition;
      Serial.println('S');
      Serial.println(spd);
      Serial.send_now();
      analogWrite(A14, spd * 20 + 500);
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
      if (USBcomFlag ==1) {
      int dig = stm[state][5];
      Serial.println(dig);
      }

      switch (stm[state][5]) { // remember zero indexing
        case 0: // all off
          allPinsLow();
          break;
        case 1: // Pin 2 ON (rewd valve)
          allPinsLow();
          digitalWrite(digioutPins[0], HIGH);
          break;
        case 2: // Pin 3 of teensy ON (vis1)
          allPinsLow();
          digitalWrite(digioutPins[1], HIGH);
          digitalWrite(digioutPins[5], HIGH); //(generic stim on)
          break;
        case 3: // Pin 4 of teensy ON  (vis2)
          allPinsLow();
          digitalWrite(digioutPins[2], HIGH);
          digitalWrite(digioutPins[5], HIGH); //(generic stim on)
          break;
        case 4: // Pin 5 of teensy ON (odr1)
          allPinsLow();
          digitalWrite(digioutPins[3], HIGH);
          digitalWrite(digioutPins[5], HIGH); //(generic stim on)
          break;
        case 5: // Pin 6 of teensy ON (odr2)
          allPinsLow();
          digitalWrite(digioutPins[4], HIGH);
          digitalWrite(digioutPins[5], HIGH); //(generic stim on)
          break;
        case 6: // Pin 7 of teensy ON (generic stim on)
          allPinsLow();
          digitalWrite(digioutPins[5], HIGH);
          break;

        case 7: // Pin 2 AND 3 of teensy ON (rewd+vis1)
          allPinsLow();
          digitalWrite(digioutPins[1], HIGH);
          digitalWrite(digioutPins[0], HIGH);
          digitalWrite(digioutPins[5], HIGH); //(generic stim on)
          break;
        case 8: // Pin 2 AND 5 of teensy ON (rewd+odr1)
          allPinsLow();
          digitalWrite(digioutPins[3], HIGH);
          digitalWrite(digioutPins[0], HIGH);
          digitalWrite(digioutPins[5], HIGH); //(generic stim on)
          break;
          /*
                case 9: // Pin 8 of teensy ON
                  allPinsLow();
                  digitalWrite(digioutPins[6],HIGH);
                  break;
                case 10: // Pin 9 of teensy ON
                  allPinsLow();
                  digitalWrite(digioutPins[7],HIGH);
                  break;

                case 11: // Pin 10 of teensy ON
                  allPinsLow();
                  digitalWrite(digioutPins[8],HIGH);
                  break;
          */
      }
      // send the new state to matlab
      //Serial.println('S');
      //Serial.println(state);
      //Serial.send_now();
      StartTime = millis();
      StartPosition = myEnc.read();
      stateJustChanged = 0;
    }
    CurrentTime = millis();
    CurrentPosition = myEnc.read();

    // Now go through the triggers

    if (spdok == 1 && state != stm[state][0]) { // speed in
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][0]; triallog += "__";
      state = stm[state][0];
      stateJustChanged = 1;

    }

    else if (spdok == 0 && state != stm[state][1]) { // speed out
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][1]; triallog += "__";
      state = stm[state][1];
      stateJustChanged = 1;
    }

    else if (lick == 1 && state != stm[state][2]) { // lick
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][2]; triallog += "__";
      state = stm[state][2];
      stateJustChanged = 1;
    }

    //else if ((CurrentTime-StartTime)>=stm[state][4] && state != stm[state][3]) { // Timeup
    else if (state == 5 || state == 7) { // use time if its for rewd
      if ((CurrentTime - StartTime) >= stm[state][4] && state != stm[state][3]) { // Timeup
        triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][3]; triallog += "__";
        state = stm[state][3];
        stateJustChanged = 1;
      }
    }
    else if ((CurrentPosition - StartPosition) * 62.83 / 4000 >= stm[state][4] && state != stm[state][3]) { // Distanceup
      triallog += millis(); triallog += "_"; triallog += state; triallog += "to"; triallog += stm[state][3]; triallog += "__";
      state = stm[state][3];
      stateJustChanged = 1;
    }

    if (state == 99) { // end the trial
      triallog += millis(); triallog += "_"; triallog += state; triallog += "_End";
      Serial.println('E');
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
        digitalWrite(ledPin, LOW);

      }
    }


  } // end while (runfsm != 0){

}

// ---- Functions-----


void establishContact() {
  int madeContact = 0;
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
