#include "fscmF.h"
#include "fscmFFunctions.h"
void setup() {
  Serial.begin(2000000);
  pinMode(13, OUTPUT);
  pinMode(12, INPUT_PULLUP);
  fscmFFSetupSensors();
  fscmFFSetupCoproc();
  fscmFFSetupRadio();
}
void loop() {
  fscmFFReadSensors();
  fscmFFRadio();
  if (gotFscmTMsgLast) {
    fscmFFCoproc();
  }
  fscmFFHomeSet();
  fscmFGAlt = fscmFFAltCalc();
  if (millis() - fscmFLastRecvMillis < SHUTOFF_AFTER_MILLIS) {//connected
    digitalWrite(13, fscmFEnabled);
  } else {//signal loss
    if (millis() % 300 < 150) {
      digitalWrite(13, HIGH);
    } else {
      digitalWrite(13, LOW);
    }
  }
}
void fscmFFDataToParseFromFscmC() {
  fscmCPitch = fscmFFParseDataFscmCFl();
  fscmCRoll = fscmFFParseDataFscmCFl();
}
void fscmFFDataToSendToFscmC() {
  fscmFFSendDataFscmCBl(fscmFEnabled);
  fscmFFSendDataFscmCBl(fscmHomeSet);
  fscmFFSendDataFscmCFl(fscmFHeading);
  fscmFFSendDataFscmCFl(fscmFPitch);
  fscmFFSendDataFscmCFl(fscmFRoll);
  fscmFFSendDataFscmCBy(jly);
  fscmFFSendDataFscmCBy(jlx);
  fscmFFSendDataFscmCBy(jry);
  fscmFFSendDataFscmCBy(jrx);
  fscmFFSendDataFscmCBy(lk);
  fscmFFSendDataFscmCBy(rk);
  fscmFFSendDataFscmCBl(lt);
  fscmFFSendDataFscmCBl(rt);
}
void fscmFFDataToSendToFscmT() {
  fscmFFSendDataFscmTBl(fscmHomeSet);
  fscmFFSendDataFscmTBy(fscmFOriSystemCal);
  fscmFFSendDataFscmTBy(fscmFOriGyroCal);
  fscmFFSendDataFscmTBy(fscmFOriAccelCal);
  fscmFFSendDataFscmTBy(fscmFOriMagCal);
  fscmFFSendDataFscmTIn(fscmFDistMeters);
  fscmFFSendDataFscmTFl(fscmFHeadFmHome);
  fscmFFSendDataFscmTFl(fscmFOriQuatX);
  fscmFFSendDataFscmTFl(fscmFOriQuatY);
  fscmFFSendDataFscmTFl(fscmFOriQuatZ);
  fscmFFSendDataFscmTFl(fscmFOriQuatW);
  fscmFFSendDataFscmTFl(fscmFGpsLon);
  fscmFFSendDataFscmTFl(fscmFGpsLat);
  fscmFFSendDataFscmTFl(fscmFGpsSatStat);
  fscmFFSendDataFscmTFl(fscmFGpsSpeed);
  fscmFFSendDataFscmTFl(fscmFGpsHeading);
  fscmFFSendDataFscmTFl(fscmFGAlt);
  fscmFFSendDataFscmTFl(fscmFBatVolt);
  fscmFFSendDataFscmTIn(fscmFSigStrengthOfTran);
  fscmFFSendDataFscmTFl(fscmCPitch);
  fscmFFSendDataFscmTFl(fscmCRoll);
}
void fscmFFDataToParseFromFscmT() {
  fscmRequestHomeSet = fscmFFParseDataFscmTBl();
  fscmFEnabled = fscmFFParseDataFscmTBy();
  jly = fscmFFParseDataFscmTBy();
  jlx = fscmFFParseDataFscmTBy();
  jry = fscmFFParseDataFscmTBy();
  jrx = fscmFFParseDataFscmTBy();
  lk = fscmFFParseDataFscmTBy();
  rk = fscmFFParseDataFscmTBy();
  lt = fscmFFParseDataFscmTBl();
  rt = fscmFFParseDataFscmTBl();
}
