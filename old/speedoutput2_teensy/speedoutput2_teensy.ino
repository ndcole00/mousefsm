
#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder.
Encoder myEnc(0, 1);

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
  analogWriteResolution(12);
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
      //Serial.flush();
      //Serial.println(newPosition);
      Serial.println(spd);
      Serial.send_now();
      //Serial.println(ledPin);
      analogWrite(A14, spd*50);
      
      
    }
}
