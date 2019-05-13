#include "fscmCFunctions.h"
#include "fscmC.h"
void setup() {
  fscmCFSetupGyro();
  Serial2.begin(250000);//to fscmF
  Serial.begin(2000000);//for DEBUG
  pinMode(13, OUTPUT);
  pinMode(8, INPUT_PULLUP);
  zeroGyro();
}
void loop() {
  fscmCFReadGyro();
  fscmCFFscmFComms();
  if (fscmHomeSet) {
    zeroGyro();
  }
  if (millis() - lastRecievedFscmF < 1000) {
    if (fscmCEnabled) {
      digitalWrite(13, HIGH);
      ////////////enabled
      digitalWrite(13, LOW);
    } else { //disabled
      digitalWrite(13, LOW);
      ///////////disabled
    }
  }
  else {//lost connection
    digitalWrite(13, (millis() / 250) % 2);
    //lost connection (disable)
  }
}
void fscmCFDataToSendToFscmF() {
  fscmCFSendDataFscmFFl(fscmCPitch);
  fscmCFSendDataFscmFFl(fscmCRoll);
}
void fscmCFDataToParseFromFscmF() {
  fscmCEnabled = fscmCFParseDataFscmFBl();
  fscmHomeSet = fscmCFParseDataFscmFBl();
  fscmFHeading = fscmCFParseDataFscmFFl();
  fscmFPitch = fscmCFParseDataFscmFFl();
  fscmFRoll = fscmCFParseDataFscmFFl();
  jly = fscmCFParseDataFscmFBy();
  jlx = fscmCFParseDataFscmFBy();
  jry = fscmCFParseDataFscmFBy();
  jrx = fscmCFParseDataFscmFBy();
  lk = fscmCFParseDataFscmFBy();
  rk = fscmCFParseDataFscmFBy();
  lt = fscmCFParseDataFscmFBl();
  rt = fscmCFParseDataFscmFBl();
}
