void fscmCFFscmFComms() {
  justRecvdFscmF = false;
  if (digitalRead(8) == HIGH && Serial2.available()) {
    lastRecievedFscmF = millis();
    fscmCFDataToParseFromFscmF();
    justRecvdFscmF = true;
    pinMode(8, INPUT_PULLUP);
    digitalWrite(8, LOW);
    fscmCFDataToSendToFscmF();
    Serial2.flush();
    digitalWrite(8, HIGH);
    pinMode(8, INPUT_PULLUP);
  }
}
void fscmCFSendDataFscmFBy(byte val) {
  Serial2.write(val);
}
void fscmCFSendDataFscmFIn(int val) {
  union {
    byte b[2];
    int v;
  } d;
  d.v = val;
  Serial2.write(d.b[0]);
  Serial2.write(d.b[1]);
}
void fscmCFSendDataFscmFFl(float val) {
  union {
    byte b[4];
    float v;
  } d;
  d.v = val;
  Serial2.write(d.b[0]);
  Serial2.write(d.b[1]);
  Serial2.write(d.b[2]);
  Serial2.write(d.b[3]);
}
void fscmCFSendDataFscmFBl(boolean val) {
  Serial2.print(val);
}
boolean fscmCFParseDataFscmFBl() {
  byte msg = Serial2.read();
  if (msg == '0') {
    return false;
  }
  if (msg == '1') {
    return true;
  }
  return false;
}
byte fscmCFParseDataFscmFBy() {
  byte msg = Serial2.read();
  return msg;
}
int fscmCFParseDataFscmFIn() {
  union {
    byte b[2];
    int v;
  } d;
  d.b[0] = Serial2.read();
  d.b[1] = Serial2.read();
  return d.v;
}
float fscmCFParseDataFscmFFl() {
  union {
    byte b[4];
    float v;
  } d;
  d.b[0] = Serial2.read();
  d.b[1] = Serial2.read();
  d.b[2] = Serial2.read();
  d.b[3] = Serial2.read();
  return d.v;
}
void fscmCFSetupGyro() {
  Wire.begin();//////////////////////setup gy521
  Wire.setClock(400000L);
  Wire.beginTransmission(0x68);
  Wire.write(0x6B);
  Wire.write(0);//wakeup
  Wire.endTransmission(true);
  Wire.beginTransmission(0x68);
  Wire.write(0x1B);
  Wire.write(0x10);//gyro range //18=2000//10=1000
  Wire.endTransmission(true);
  Wire.beginTransmission(0x68);
  Wire.write(0x19);
  Wire.write(0x04);//clock devider
  Wire.endTransmission(true);
  Wire.beginTransmission(0x68);
  Wire.write(0x1A);
  Wire.write(0x00);//buffering
  Wire.endTransmission(true);///////end setup gy521
}
void fscmCFReadGyro() {
  Wire.beginTransmission(0x68);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(0x68, 14, true);
  cfAX = Wire.read() << 8 | Wire.read();
  cfAY = Wire.read() << 8 | Wire.read();
  cfAZ = Wire.read() << 8 | Wire.read();
  Wire.read(); Wire.read();//throw away temperature
  cfGX = Wire.read() << 8 | Wire.read();
  cfGY = Wire.read() << 8 | Wire.read();
  cfGZ = Wire.read() << 8 | Wire.read();
  GDSX = (cfGX - GX0) * 1000.00 / 32766;
  GDSY = (cfGY - GY0) * 1000.00 / 32766;
  GDSZ = (cfGZ - GZ0) * 1000.00 / 32766;
  fscmCPitch = .99 * (fscmCPitch + GDSX * (millis() - lastCalcedGyro) / 1000.000) + .01 * degrees(atan2(cfAY, cfAZ));
  fscmCRoll = .99 * (fscmCRoll + GDSY * (millis() - lastCalcedGyro) / 1000.000) + .01 * degrees(atan2(-cfAX, cfAZ));
  lastCalcedGyro = millis();
}
void zeroGyro() {
  digitalWrite(13, HIGH);
  GX0 = 0; GY0 = 0; GZ0 = 0;
  for (int i = 0; i < 40; i++) {
    Wire.beginTransmission(0x68);
    Wire.write(0x3B);
    Wire.endTransmission(false);
    Wire.requestFrom(0x68, 14, true);
    cfAX = Wire.read() << 8 | Wire.read();
    cfAY = Wire.read() << 8 | Wire.read();
    cfAZ = Wire.read() << 8 | Wire.read();
    Wire.read(); Wire.read();//throw away temperature
    cfGX = Wire.read() << 8 | Wire.read();
    cfGY = Wire.read() << 8 | Wire.read();
    cfGZ = Wire.read() << 8 | Wire.read();
    GX0 += cfGX;
    GY0 += cfGY;
    GZ0 += cfGZ;
    delay(10 + i / 5);
  }
  GX0 /= 40;
  GY0 /= 40;
  GZ0 /= 40;
  digitalWrite(13, LOW);
}
