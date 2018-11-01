
int ledPin=13;

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
  while (Serial.available()==0)  {
    //digitalWrite(ledPin,HIGH);
    //delay(500);
    //digitalWrite(ledPin,LOW);
    //delay(500);
    //wait till there are some numbers
  }
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
    // error
    while (1){
      digitalWrite(ledPin,HIGH);
      delay(200);
      digitalWrite(ledPin,LOW);
      delay(50);
    }
  }
  
  // ------Now you have the state matrix------
  // ------start the state machine------
  
  
  
}

// ---- Functions-----


void establishContact() {
  int madeContact = 0;
  while (madeContact ==0) {
    digitalWrite(ledPin,HIGH);
    delay(100);
    digitalWrite(ledPin,LOW);
    delay(100);
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
    
