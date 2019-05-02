// Streamlick signals to Tools > Serial Plotter
// Adil Khan, London 2019
// 3.3V is 1024

int ledPin = 13;
int SensorValue1;
int SensorValue2;
int Ymax = 3000; // mV
int Ymin = 0;// mV
int Sfreq = 40;// Sampling Freq Hz 
int threshA = .5*1000;//
int threshB = .7*1000 + 1000;//


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
    Serial.print(threshA);
    Serial.print(" ");
    Serial.print(threshB);
    Serial.print(" ");
    Serial.print(SensorValue1);//With 1 V offset
    Serial.print(" ");
    Serial.println(SensorValue2+1000);
    digitalWrite(ledPin, LOW);
    delay(10);
    digitalWrite(ledPin, HIGH);
  }

}
