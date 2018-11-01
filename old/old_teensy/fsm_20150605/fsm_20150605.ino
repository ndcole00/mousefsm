
#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder.
Encoder myEnc(0, 1);

int ledPin=13;
int runfsm = 0;
int spdRngHi;
int spdRngLo;

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
  int nRows   = Serial.parseInt();
  int nCols   = Serial.parseInt();
  int spdBin  = Serial.parseInt();
  spdRngHi = Serial.parseInt();
  spdRngLo = Serial.parseInt();
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
  Serial.println('D');
 
  // now Matlab will send a '>' to signal end of transmission
  while(!Serial.available()) ; // hang program until a byte is received
  
  char endChar = Serial.read();
  Serial.flush();
   
  if (endChar != '>') {
    // error, start again
     runfsm = 0;
     Serial.println("Error1");
     //Serial.flush();
     while (Serial.available()){
       int dump = Serial.read();//clear input buffer
     }
     
     delay(1000);
       
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
  unsigned long spdPrevMillis = 0; 
  unsigned long spdCurrMillis = millis(); 
  long oldPosition = myEnc.read();
  long newPosition;
  
  
  while (runfsm != 0){
    // Check speed every x ms without pausing
    spdCurrMillis = millis();
    if (spdCurrMillis-spdPrevMillis >= spdBin){
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd = (newPosition-oldPosition)*62.83/(4*spdBin);
      oldPosition = newPosition;
      Serial.println(spd);
      Serial.send_now();
    }
   
    spdok = checkSpeed(spd);
     if (analogRead(0)>100) {
       lick = 1;
     }
     else {
         lick = 0;        
     }
    
    if (stateJustChanged == 1) {
      // send digiout
      
      switch (stm[state][5]) { // remember zero indexing
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
    
    else if (lick == 1 && state != stm[state][2]) { // lick
      state = stm[state][2];
      stateJustChanged = 1;
    }
    
    else if ((CurrentTime-StartTime)>=stm[state][4] && state != stm[state][3]) { // Timeup
      state = stm[state][3];
      stateJustChanged = 1;
    }
            
    if (state == 99){ // end the trial
      Serial.println('E');
      runfsm = 0;
    }
    if (Serial.available()>0){ // if user clicks stop
      char stopChar = Serial.read();
      if (stopChar == 'X') {
        runfsm = 0;
        digitalWrite(ledPin,LOW);
        
      }
    }
    
    
  } // end while (runfsm != 0){
  
}

// ---- Functions-----


void establishContact() {
  int madeContact = 0;
  while (madeContact ==0) {
   /* digitalWrite(ledPin,HIGH);
    delay(50);
    digitalWrite(ledPin,LOW);
    delay(50); */
    if (Serial.available() > 0)  {
      char recvd = Serial.read();
      if (recvd =='A') {
        while (Serial.available()){
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
    
    
int checkSpeed(int spd){
  int sok;
  if (spd > spdRngLo && spd < spdRngHi){
    sok = 1;
  }
  else {
    sok = 0;
  }
  return sok;
}
