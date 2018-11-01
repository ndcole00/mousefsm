 
   int ledPin=13;
   int var1;
   int i = 1;
   double t = 0;
   double s = 0;
   
   void setup() {
   pinMode(13, OUTPUT);
   //start serial port at 9600 bps:
   Serial.begin(9600);
   digitalWrite(ledPin,HIGH);
   establishContact();  // send a byte to establish contact until receiver responds
   digitalWrite(ledPin,LOW);
   s=millis();
 }

 void loop() 
 {
   if (Serial.available() > 0) 
   {
     var1 = Serial.read();
     Serial.print(var1);
     if (i==1) 
     {
       digitalWrite(ledPin,LOW);
       i=2;
       delay(500);
     }
     else if (i==2)
     { 
       digitalWrite(ledPin,HIGH);
       i=1;
       delay(500);
       //digitalWrite(ledPin,LOW);
     }
   }
 }

 void establishContact() {
     while (Serial.available() <= 0) {
       Serial.println('AA');   // send a capital A
       delay(300);
     }
 }

