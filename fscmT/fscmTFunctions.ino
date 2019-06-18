void fscmTFFscmFComms() {
  if (fscmTRecvdFscmFNew == true) {
    fscmTReadyToSendToFscmD = true;
  }
  fscmTRecvdFscmFNew = false;
  uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
  uint8_t len = sizeof(buf);
  rf95.waitPacketSent();
  if (rf95.recv(buf, &len)) {
    fscmTRecvdFscmFNew = true;
    fscmTLastMillisRecvFscmF = millis();
    fscmTLastMillisTransFscmF = millis();
    for (int i = 0; i < len; i++) {
      fscmFRBuf[i] = buf[i];
    }
    fscmTSigStrengthFromF = rf95.lastRssi();
    fscmFRI = 0;
    fscmTFDataToParseFromFscmF();
    fscmFRI = 0;
    fscmTFDataToSendToFscmF();
    uint8_t data[fscmFRI];
    for (int i = 0; i < fscmFRI; i++) {
      data[i] = fscmFRBuf[i];
    }
    rf95.send(data, sizeof(data));
  } else if (millis() - fscmTLastMillisTransFscmF > 500) {
    fscmTLastMillisTransFscmF = millis();
    fscmFRI = 0;
    fscmTFDataToSendToFscmF();
    uint8_t data[fscmFRI];
    for (int i = 0; i < fscmFRI; i++) {
      data[i] = fscmFRBuf[i];
    }
    rf95.send(data, sizeof(data));
  }
}
void fscmTFSendDataFscmFBl(boolean val) {
  fscmFRBuf[fscmFRI] = val;
  fscmFRI++;
}
void fscmTFSendDataFscmFBy(byte val) {
  fscmFRBuf[fscmFRI] = val;
  fscmFRI++;
}
void fscmTFSendDataFscmFIn(int val) {
  union {
    byte b[2];
    int v;
  } d;
  d.v = val;
  fscmFRBuf[fscmFRI] = d.b[0];
  fscmFRI++;
  fscmFRBuf[fscmFRI] = d.b[1];
  fscmFRI++;
}
void fscmTFSendDataFscmFFl(float val) {
  union {
    byte b[4];
    float v;
  } d;
  d.v = val;
  fscmFRBuf[fscmFRI] = d.b[0];
  fscmFRI++;
  fscmFRBuf[fscmFRI] = d.b[1];
  fscmFRI++;
  fscmFRBuf[fscmFRI] = d.b[2];
  fscmFRI++;
  fscmFRBuf[fscmFRI] = d.b[3];
  fscmFRI++;
}
boolean fscmTFParseDataFscmFBl() {
  fscmFRI++;
  return fscmFRBuf[fscmFRI - 1];
}
byte fscmTFParseDataFscmFBy() {
  fscmFRI++;
  return fscmFRBuf[fscmFRI - 1];
}
int fscmTFParseDataFscmFIn() {
  union {
    byte b[2];
    int v;
  } d;
  d.b[0] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  d.b[1] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  return d.v;
}
float fscmTFParseDataFscmFFl() {
  union {
    byte b[4];
    float v;
  } d;
  d.b[0] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  d.b[1] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  d.b[2] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  d.b[3] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  return d.v;
}
void fscmTFSetupFComms() {
  if (!rf95.init()) {
    while (1);
  }
  rf95.setFrequency(RF95_FREQ);
  rf95.setTxPower(23, false);
}
void fscmTFFscmDComms() {
  if (fscmTReadyToSendToFscmD == true || (millis() - fscmTLastMillisRecvFscmF > 1000 && millis() - fscmTLastMillisSentFscmD > 1000)) {
    fscmTLastMillisSentFscmD = millis();
    fscmTReadyToSendToFscmD = false;
    if (Serial) {
      Serial.flush();
      Serial.print("<0,");
      fscmTFDataToSendToFscmD();
      Serial.print("0");
      Serial.print(">");
    }
  }
  while (Serial.available() > 0) {
    if (Serial.read() == '<') {
      fscmTFDataToParseFromFscmD();
    }
  }
}
void fscmTFSendDataFscmDBy(byte d) {
  Serial.print(d);
  Serial.print(",");
}
void fscmTFSendDataFscmDIn(int d) {
  Serial.print(d);
  Serial.print(",");
}
void fscmTFSendDataFscmDFl(float d) {
  Serial.print(d, 8);
  Serial.print(",");
}
void fscmTFSendDataFscmDBl(boolean d) {
  Serial.print(d);
  Serial.print(",");
}
boolean fscmTFParseDataFscmDBl() {
  int msg = Serial.parseInt();
  if (msg == 0) {
    return false;
  } else if (msg != -1) {
    return true;
  }
  return false;
}
byte fscmTFParseDataFscmDBy() {
  int msg = Serial.parseInt();
  return msg;
}
int fscmTFParseDataFscmDIn() {
  int msg = Serial.parseInt();
  return msg;
}
float fscmTFParseDataFscmDFl() {
  float msg = Serial.parseFloat();
  return msg;
}
void fscmTFSetupIO() {
  pinMode(LJXPin, INPUT);
  pinMode(LJYPin, INPUT);
  pinMode(RJXPin, INPUT);
  pinMode(RJYPin, INPUT);
  pinMode(LKPin, INPUT);
  pinMode(RKPin, INPUT);
  pinMode(RTPin, INPUT_PULLUP);
  pinMode(LTPin, INPUT_PULLUP);
  pinMode(ETPin, INPUT_PULLUP);
  pinMode(RBPin, INPUT_PULLUP);
  pinMode(LBPin, INPUT_PULLUP);
  pinMode(TBATMPin, INPUT);
  FastLED.addLeds<WS2812, LEDPin, RGB>(ledCA, 10);
  FastLED.show();
}
void fscmTFSetupDComms() {
  Serial.begin(2000000);
  Serial.setTimeout(50);
}
void fscmTFReadInputs() {
  fscmTLJXBVal = constrain(map(analogRead(LJXPin), 106, 899, 0, 255), 0, 255);
  fscmTLJYBVal = constrain(map(analogRead(LJYPin), 199, 816, 0, 255), 0, 255);
  fscmTRJXBVal = constrain(map(analogRead(RJXPin), 898, 168, 0, 255), 0, 255);
  fscmTRJYBVal = constrain(map(analogRead(RJYPin), 143, 797, 0, 255), 0, 255);
  fscmTLKBVal = constrain(map(analogRead(LKPin), 0, 1023, 0, 255), 0, 255);
  fscmTRKBVal = constrain(map(analogRead(RKPin), 0, 1023, 0, 255), 0, 255);
  fscmTLJXIVal = analogRead(LJXPin);
  fscmTLJYIVal = analogRead(LJYPin);
  fscmTRJXIVal = analogRead(RJXPin);
  //  fscmTRJYIVal = analogRead(RJYPin);
  //  Serial.println();
  //  Serial.print(fscmTLJXIVal); Serial.print(",");
  //  Serial.print(fscmTLJYIVal); Serial.print(",");
  //  Serial.print(fscmTRJXIVal); Serial.print(",");
  //  Serial.print(fscmTRJYIVal); Serial.println(",");
  fscmTLKIVal = analogRead(LKPin);
  fscmTRKIVal = analogRead(RKPin);
  fscmTRTVal = (digitalRead(RTPin) == LOW);
  fscmTLTVal = (digitalRead(LTPin) == LOW);
  fscmTETVal = (digitalRead(ETPin) == LOW);
  fscmTRBVal = (digitalRead(RBPin) == LOW);
  fscmTLBVal = (digitalRead(LBPin) == LOW);
  fscmTBatVVal = analogRead(TBATMPin) * 2.4 * 3.3 / 1024;
}
void fscmTFSetStatLed(int num, CRGB c) {
  ledCA[num] = c;
  FastLED.show();
}
