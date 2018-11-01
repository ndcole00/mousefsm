
#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder.
Encoder myEnc(2, 3);

int ledPin=13;
int runfsm = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  Serial.setTimeout(10);
}


void loop()
{
  // start of trial
  // Matlab should be sending 'A' constantly
  // read it, reply with 'B'
  // then Matlab will send nRows nCols and stm
  establishContact();
  while(!Serial.available()) ; // hang program until a byte is received
  int nRows = Serial.parseInt();
  int nCols = Serial.parseInt();
  // send a signal to say its received
  Serial.println('C');
  
  // now Matlab will send stm
  int stm[nRows][nCols];
  //Serial.println(nRows);
  
  for (int r=0; r<nRows; r++) {
   for (int c=0;c<nCols;c++) {
     while(!Serial.available()) ; // hang program until a byte is received
     stm[r][c] = Serial.parseInt();
     
   }
  }
  Serial.println('M');
  
  // now Matlab will send a '>' to signal end of transmission
  while(!Serial.available()) ; // hang program until a byte is received
  char endChar = Serial.read();
  if (endChar != '>') {
    // error, start again
     runfsm = 0;
     Serial.println("Error1");
     }
   else {
     runfsm = 1;
   }
  
  // ------Now you have the state matrix------
  // ------start the state machine------
  
  int state = 0; // remember zero indexing
 
  int spdok;
  int spd = 0;
  int stateJustChanged = 1;
  unsigned long StartTime = millis();
  unsigned long CurrentTime = millis();
  unsigned long spdPrevMillis = 0; 
  unsigned long spdCurrMillis = millis(); 
  long oldPosition = myEnc.read();
  long newPosition;
  
  
  while (runfsm != 0){
    // Check speed every x ms without pausing
    spdCurrMillis = millis();
    if (spdCurrMillis-spdPrevMillis > 50){
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd = (newPosition-oldPosition)/1;
      oldPosition = newPosition;
      //Serial.println(spd);
    }
   
    spdok = checkSpeed(spd);
    
    if (stateJustChanged == 1) {
      // send digiout
      
      switch (stm[state][4]) { // remember zero indexing
      case 0:
        digitalWrite(ledPin,LOW);
        break;
      case 1:
        digitalWrite(ledPin,HIGH);
        break;
      }
      StartTime = millis();
      stateJustChanged = 0;
    }
    CurrentTime = millis();
    
    // Now go through the triggers
    
    if (spdok == 1 && state != stm[state][0]) { // speed in
      state = stm[state][0];
      stateJustChanged = 1;
    }
    
    else if (spdok == 0 && state != stm[state][1]) { // speed out
      state = stm[state][1];
      stateJustChanged = 1;
    }
    
    else if ((CurrentTime-StartTime)>stm[state][3] && state != stm[state][2]) { // Timeup
      state = stm[state][2];
      stateJustChanged = 1;
    }
            
    if (state == 99){ // end the trial
      Serial.println('E');
      runfsm = 0;
    }      
    //Serial.println(CurrentTime-StartTime);
  } // end while (runfsm != 0){
  
}

// ---- Functions-----


void establishContact() {
  int madeContact = 0;
  while (madeContact ==0) {
    digitalWrite(ledPin,HIGH);
    delay(500);
    digitalWrite(ledPin,LOW);
    delay(500);
    if (Serial.available() > 0)  {
      char recvd = Serial.read();
      if (recvd =='A') {
        Serial.flush();
        Serial.println('B');
        madeContact = 1;
      }
    }
  }
}
    
    
int checkSpeed(int spd){
  int sok;
  if (spd > 5 && spd < 20){
    sok = 1;
  }
  else {
    sok = 0;
  }
  return sok;
}
