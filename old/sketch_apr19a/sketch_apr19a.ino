boolean started = false;
boolean ended = false;
int buff[101];
int serialIn = 0;
int serialOut = 0;
int incomingByte;
int ledPin=13;
int i=0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.setTimeout(10);
  pinMode(13, OUTPUT);
  digitalWrite(ledPin,HIGH);
  delay(100);
  digitalWrite(ledPin,LOW);
  delay(100);
}




void loop()
{
  while(Serial.available() > 0)
  {
       
        //incomingByte = Serial.read();
        incomingByte = Serial.parseInt();
        buff[serialIn] = incomingByte;
        Serial.println(incomingByte);
        
        //Serial.println(buff);
        
        serialIn++;
        buff[serialIn] = '\0';
        if (buff[serialIn-1] == 5)
        {
        digitalWrite(ledPin,HIGH);
        delay(200);
        digitalWrite(ledPin,LOW);
        delay(200);
        }
  
  }
}

