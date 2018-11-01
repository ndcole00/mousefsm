int ledPin=13;
int index;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  digitalWrite(ledPin,HIGH);
  delay(1000);
  digitalWrite(ledPin,LOW);
  delay(1000);
}

void loop() {
  // put your main code here, to run repeatedly:

//String content = "";
char content;
if (Serial.available()>0) {
  //while (Serial.available()) {
    content = Serial.read();
    digitalWrite(ledPin,HIGH);
 // }
}

long data[3]; //The results will be stored here
for(int i = 0; i < 3; i++){
  //index = content.indexOf(","); //We find the next comma
  //data[i] = atol(content.substring(0,index).c_str()); //Extract the number
  //content = content.substring(index+1); //Remove the number from the string
}
Serial.println(content);
delay(1000);
/*
while (1)
  digitalWrite(ledPin,HIGH);
  delay(data[1]);
  digitalWrite(ledPin,LOW);
  delay(data[2]);
*/

}
