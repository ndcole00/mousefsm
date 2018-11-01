boolean started = false;
boolean ended = false;
int buff[10][10];
int serialIn = 0;
int serialOut = 0;
int incomingByte;
int ledPin=13;
int i=0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  
}




void loop()
{
  while(Serial.available() > 0)
  {
     int aChar = Serial.read();
     if(aChar == '<')
     {
        started = true;
        ended = false;
        //Serial.println("n1");
     }
     else if(aChar == '>')
     {
        ended = true;
        //Serial.println("n2");
        break; // Break out of the while loop
     }
     else if (started == true)
     {
       
        buff[1][serialIn] = aChar;
        //Serial.println(buff);
        serialIn++;
        buff[1][serialIn] = '\0';
     }
  }

  if(started && ended)
  {
     // We got a whole packet
     
     //Serial.println(buff[1]);
     if (buff[1][1] == '5')
     {
       digitalWrite(ledPin,HIGH);
       delay(1000);
       digitalWrite(ledPin,LOW);
     }
     else {
       digitalWrite(ledPin,HIGH);
       delay(50);
       digitalWrite(ledPin,LOW);
     }
     serialIn = 0;
     buff[1][serialIn] = '\0';

     started = false;
     ended = false;
  }
  else
  {
    // No data, or only some data, received
    
  }
}

