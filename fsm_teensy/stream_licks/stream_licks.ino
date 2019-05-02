// Streamlick signals to Tools > Serial Plotter
// Adil Khan, London 2019
// 3.3V is 1024

int ledPin = 13;
int SensorValue1;
int SensorValue2;
int Ymax = 2000; // mV
int Ymin = 0;// mV
int Sfreq = 40;// Sampling Freq Hz 

unsigned long PrevMillis = millis();
unsigned long CurrMillis = millis();

void setup() {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
}


void loop()
{

  //Send values to Serial Port every x ms without pausing
  CurrMillis = millis();
  if (CurrMillis - PrevMillis >= 1000/Sfreq) {
    PrevMillis = CurrMillis;
    SensorValue1 = analogRead(0) * 3.3*1000/1024;//mV
    SensorValue2 = analogRead(1) * 3.3*1000/1024;//mV
    Serial.print(Ymax);
    Serial.print(" ");
    Serial.print(Ymin);
    Serial.print(" ");
    Serial.print(SensorValue1+1000);//With 1 V offset
    Serial.print(" ");
    Serial.println(SensorValue2);
    digitalWrite(ledPin, LOW);
    delay(10);
    digitalWrite(ledPin, HIGH);
  }

}
