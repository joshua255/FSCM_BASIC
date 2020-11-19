#include "fscmTFunctions.h"
#include "fscmT.h"
void setup() {
  fscmTFSetupIO();
  fscmTFSetupFComms();
  fscmTFSetupDComms();
}
void loop() {
  fscmTFReadInputs();
  if (fscmDWarnings) {
    fscmTFSetStatLed(ledLeftID, CRGB(255, 0, 0));
  } else {
    if (fscmTLTVal) {
      fscmTFSetStatLed(ledLeftID, CHSV(map(fscmTLKBVal / 30, 0, 9, 30, 235), 200, 150));
    } else {
      fscmTFSetStatLed(ledLeftID, CRGB(5, 5, 5));
    }
  }
  fscmTFSetStatLed(ledTogLightID, CRGB(fscmTETVal * 255, fscmTETVal * 250 + !fscmTETVal * 35, !fscmTETVal * 8 + fscmTETVal * 140));
  fscmTFFscmDComms();
  fscmTFFscmFComms();
  fscmTFLedDisplay();
}
void fscmTFLedDisplay() {
  //rainbows!

  fscmTFSetStatLed(ledTranBatStatID, CRGB(constrain(map(fscmFBatVolt * 1000, 3500, 4200, 100, 0), 0, 100), constrain(map(fscmFBatVolt * 1000, 3500, 4200, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledBatStatTopID, CRGB(constrain(map(batVoltage * 1000 / 3, 3800, 4200, 100, 0), 0, 100), constrain(map(batVoltage * 1000 / 3, 3800, 4200, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledBatStatMidID, CRGB(constrain(map(batVoltage * 1000 / 3, 3400, 3800, 100, 0), 0, 100), constrain(map(batVoltage * 1000 / 3, 3400, 3800, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledBatStatBotID, CRGB(constrain(map(batVoltage * 1000 / 3, 3000, 3400, 100, 0), 0, 255), constrain(map(batVoltage * 1000 / 3, 3000, 3400, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledStatOneID, CHSV(constrain(map(fscmFSigStrengthOfTran, -20, -110, 235, 0), 0, 235), 255, 255));
  fscmTFSetStatLed(ledStatTwoID, CHSV(constrain(map(fscmTSigStrengthFromF, -20, -110, 235, 0), 0, 235), 255, 255));
  if (fscmTRecvdFscmFNew) {
    fscmTFSetStatLed(ledConnID, CRGB(5, 255, 30));
  } else {
    if (millis() - fscmTLastMillisTransFscmF > 300) {
      fscmTFSetStatLed(ledConnID, CRGB(255, 5, 5));
    } else {
      fscmTFSetStatLed(ledConnID, CRGB(0, 0, 0));
    }
  }
}
void fscmTFDataToParseFromFscmF() {
  fscmHomeSet = fscmTFParseDataFscmFBl();
  fscmFOriSystemCal = fscmTFParseDataFscmFBy();
  fscmFOriGyroCal = fscmTFParseDataFscmFBy();
  fscmFOriAccelCal = fscmTFParseDataFscmFBy();
  fscmFOriMagCal = fscmTFParseDataFscmFBy();
  fscmFDistMeters = fscmTFParseDataFscmFIn();
  fscmFHeadFmHome = fscmTFParseDataFscmFFl();
  fscmFOriQuatX = fscmTFParseDataFscmFFl();
  fscmFOriQuatY = fscmTFParseDataFscmFFl();
  fscmFOriQuatZ = fscmTFParseDataFscmFFl();
  fscmFOriQuatW = fscmTFParseDataFscmFFl();
  fscmFGpsLon = fscmTFParseDataFscmFFl();
  fscmFGpsLat = fscmTFParseDataFscmFFl();
  fscmFGpsSatStat = fscmTFParseDataFscmFFl();
  fscmFGpsSpeed = fscmTFParseDataFscmFFl();
  fscmFGpsHeading = fscmTFParseDataFscmFFl();
  fscmFGpsAlt = fscmTFParseDataFscmFFl();
  fscmFGAlt = fscmTFParseDataFscmFFl();
  fscmFBatVolt = fscmTFParseDataFscmFFl();
  fscmFSigStrengthOfTran = fscmTFParseDataFscmFIn();
  fscmCPitch = fscmTFParseDataFscmFFl();
  fscmCRoll = fscmTFParseDataFscmFFl();
  fscmFWPI = fscmTFParseDataFscmFBy();
  fscmFWH = fscmTFParseDataFscmFFl();
  fscmFWD = fscmTFParseDataFscmFFl();
  fscmFWA = fscmTFParseDataFscmFFl();
  inControl = fscmTFParseDataFscmFBl();
  receiverOffline = fscmTFParseDataFscmFBl();
  batVoltage = fscmTFParseDataFscmFFl();
  busVoltage = fscmTFParseDataFscmFFl();
}
void fscmTFDataToSendToFscmF() {
  fscmTFSendDataFscmFBl(fscmRequestHomeSet);
  fscmTFSendDataFscmFBl(fscmTETVal);//enable
  fscmTFSendDataFscmFBy(fscmTLJYBVal);
  fscmTFSendDataFscmFBy(fscmTLJXBVal);
  fscmTFSendDataFscmFBy(fscmTRJYBVal);
  fscmTFSendDataFscmFBy(fscmTRJXBVal);
  fscmTFSendDataFscmFBy(fscmTLKBVal);
  fscmTFSendDataFscmFBy(fscmTRKBVal);
  fscmTFSendDataFscmFBy(fscmTLTVal);
  fscmTFSendDataFscmFBl(fscmTRTVal);
  fscmTFSendDataFscmFBy(pointsWNum);
  fscmTFSendDataFscmFBy(pointsWI);
  fscmTFSendDataFscmFFl(pointsWLon);
  fscmTFSendDataFscmFFl(pointsWLat);
  fscmTFSendDataFscmFFl(pointsWAlt);
  fscmTFSendDataFscmFFl(WaypointCloseEnoughDist);
}
void fscmTFDataToSendToFscmD() {
  fscmTFSendDataFscmDBl(fscmHomeSet);
  fscmTFSendDataFscmDBy(fscmFOriSystemCal);
  fscmTFSendDataFscmDBy(fscmFOriGyroCal);
  fscmTFSendDataFscmDBy(fscmFOriAccelCal);
  fscmTFSendDataFscmDBy(fscmFOriMagCal);
  fscmTFSendDataFscmDFl(fscmFGpsLon);
  fscmTFSendDataFscmDFl(fscmFGpsLat);
  fscmTFSendDataFscmDFl(fscmFGpsSatStat);
  fscmTFSendDataFscmDFl(fscmFGpsSpeed);
  fscmTFSendDataFscmDFl(fscmFGpsHeading);
  fscmTFSendDataFscmDFl(fscmFGpsAlt);
  fscmTFSendDataFscmDIn(fscmFDistMeters);
  fscmTFSendDataFscmDFl(fscmFHeadFmHome);
  fscmTFSendDataFscmDFl(fscmFOriQuatX);
  fscmTFSendDataFscmDFl(fscmFOriQuatY);
  fscmTFSendDataFscmDFl(fscmFOriQuatZ);
  fscmTFSendDataFscmDFl(fscmFOriQuatW);
  fscmTFSendDataFscmDFl(fscmFGAlt);
  fscmTFSendDataFscmDFl(fscmFBatVolt);
  fscmTFSendDataFscmDIn(fscmFSigStrengthOfTran);
  fscmTFSendDataFscmDIn(fscmTSigStrengthFromF);
  fscmTFSendDataFscmDFl(fscmTBatVVal);
  fscmTFSendDataFscmDBy(fscmTRJXBVal);
  fscmTFSendDataFscmDBy(fscmTRJYBVal);
  fscmTFSendDataFscmDBy(fscmTLJXBVal);
  fscmTFSendDataFscmDBy(fscmTLJYBVal);
  fscmTFSendDataFscmDBy(fscmTLKBVal);
  fscmTFSendDataFscmDBy(fscmTRKBVal);
  fscmTFSendDataFscmDBl(fscmTLTVal);
  fscmTFSendDataFscmDBl(fscmTRTVal);
  fscmTFSendDataFscmDBl(fscmTLBVal);
  fscmTFSendDataFscmDBl(fscmTRBVal);
  fscmTFSendDataFscmDBl(fscmTETVal);
  fscmTFSendDataFscmDIn(int(millis() - fscmTLastMillisRecvFscmF));
  fscmTFSendDataFscmDFl(fscmCPitch);
  fscmTFSendDataFscmDFl(fscmCRoll);
  fscmTFSendDataFscmDBy(fscmFWPI);
  fscmTFSendDataFscmDFl(fscmFWH);
  fscmTFSendDataFscmDFl(fscmFWD);
  fscmTFSendDataFscmDFl(fscmFWA);
  fscmTFSendDataFscmDBl(inControl);
  fscmTFSendDataFscmDBl(receiverOffline);
  fscmTFSendDataFscmDFl(batVoltage);
  fscmTFSendDataFscmDFl(busVoltage);
}
void fscmTFDataToParseFromFscmD() {
  fscmRequestHomeSet = fscmTFParseDataFscmDBl();
  fscmDWarnings = fscmTFParseDataFscmDBl();
  pointsWNum = fscmTFParseDataFscmDBy();
  pointsWI = fscmTFParseDataFscmDBy();
  pointsWLon = fscmTFParseDataFscmDFl();
  pointsWLat = fscmTFParseDataFscmDFl();
  pointsWAlt = fscmTFParseDataFscmDFl();
  WaypointCloseEnoughDist = fscmTFParseDataFscmDFl();
}
