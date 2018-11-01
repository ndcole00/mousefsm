
#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder.
Encoder myEnc(2, 3);

int ledPin=13;
int runfsm = 0;
int spd = 0;
  int stateJustChanged = 1;
  unsigned long StartTime = millis();
  unsigned long CurrentTime = millis();
  unsigned long spdPrevMillis = 0; 
  unsigned long spdCurrMillis = millis(); 
  long oldPosition = myEnc.read();
  long newPosition;
 
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  Serial.setTimeout(10);
}



void loop() {
  
  
  // Check speed every x ms without pausing
    spdCurrMillis = millis();
    if (spdCurrMillis-spdPrevMillis > 10){
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd = (newPosition-oldPosition)/1;
      oldPosition = newPosition;
      //Serial.println(spd);
      Serial.flush();
      Serial.println(spd);
      //Serial.println(ledPin);
    }
}
