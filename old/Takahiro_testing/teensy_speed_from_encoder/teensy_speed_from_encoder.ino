// FSMteensy
// Adil Khan, London 2018
// Read encoder and output speed at analog output channel

#include <Encoder.h>
// Change these two numbers to the pins connected to your encoder A and B lines.
Encoder myEnc(0, 1);



void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.setTimeout(10);
  analogWriteResolution(12); // Analog channel is 14

    
  int spd = 0;
  int spdBin = 5; //Time bin in ms for calculating speed
  int clicksPerRev = 1000; // determined by encoder, multiplied by 4 later since its a quadrature encoder
  int wheelDiameter = 20; // in cm

  unsigned long spdPrevMillis = millis();
  unsigned long spdCurrMillis = millis();
  long oldPosition = myEnc.read();
  long newPosition;
}


void loop()
{

    // Check speed every x ms without pausing
    spdCurrMillis = millis();
    if (spdCurrMillis - spdPrevMillis >= spdBin) {
      spdPrevMillis = spdCurrMillis;
      newPosition = myEnc.read();
      spd = (newPosition - oldPosition) * 3.14 * wheelDiameter * 1000 / (4 * clicksPerRev * spdBin); // speed in cm/sec      
      oldPosition = newPosition;
      analogWrite(A14, spd * 20 + 500); // Added offset to be able to get some negative speeds
      // The actual speed in cm/s will need to be back calculated from this
      // 12 bit means 4095 is 3.3V 
      // 500 is 3.3*500/4095 V ~ .4V
      // 20 is 3.3*20/4095 V ~ .016V
      // speed in cm/s = (outputVoltage - .4)/.016
      
    }

// Can add more code here
    
}

