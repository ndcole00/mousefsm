void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  int bytesSent = Serial.write("hello"); 
  Serial.println(bytesSent);
  delay (1000);
  bytesSent = Serial.write(bytesSent); 
  Serial.println(bytesSent);
  delay (1000);
}
