#include "fscmTFunctions.h"
#include "fscmT.h"
void setup() {
  fscmTFSetupIO();
  fscmTFSetupFComms();
  fscmTFSetupDComms();
}
void loop() {
  fscmTFReadInputs();
  fscmTFSetStatLed(ledTogLightID, CRGB(fscmTETVal * 255, fscmTETVal * 250 + !fscmTETVal * 35, !fscmTETVal * 8 + fscmTETVal * 140));
  fscmTFFscmFComms();
  fscmTFFscmDComms();
  fscmTFLedDisplay();
}
void fscmTFLedDisplay() {
  //rainbows!
  fscmTFSetStatLed(ledLeftID, CRGB(fscmDWarnings * 255, !fscmDWarnings * 15, 0));
  fscmTFSetStatLed(ledBatStatTopID, CRGB(constrain(map(fscmFBatVolt * 1000, 3800, 4200, 100, 0), 0, 100), constrain(map(fscmFBatVolt * 1000, 3800, 4200, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledBatStatMidID, CRGB(constrain(map(fscmFBatVolt * 1000, 3400, 3800, 100, 0), 0, 100), constrain(map(fscmFBatVolt * 1000, 3400, 3800, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledBatStatBotID, CRGB(constrain(map(fscmFBatVolt * 1000, 3000, 3400, 100, 0), 0, 255), constrain(map(fscmFBatVolt * 1000, 3000, 3400, 0, 100), 0, 100), 0));
  fscmTFSetStatLed(ledStatOneID, CHSV(constrain(map(fscmFSigStrengthOfTran, 0, -100, 255, 0), 0, 255), 255, 255));
  fscmTFSetStatLed(ledStatTwoID, CHSV(constrain(map(fscmTSigStrengthFromF, 0, -100, 255, 0), 0, 255), 255, 255));
  if (fscmTRecvdFscmFNew) {
    fscmTFSetStatLed(ledConnID, CRGB(5, 255, 30));
  } else {
    if (millis() - fscmTLastMillisTransFscmF > 500) {
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
  fscmFGAlt = fscmTFParseDataFscmFFl();
  fscmFBatVolt = fscmTFParseDataFscmFFl();
  fscmFSigStrengthOfTran = fscmTFParseDataFscmFIn();
  fscmCPitch = fscmTFParseDataFscmFFl();
  fscmCRoll = fscmTFParseDataFscmFFl();
  fscmFWPI = fscmTFParseDataFscmFBy();
  fscmFWH = fscmTFParseDataFscmFFl();
  fscmFWD = fscmTFParseDataFscmFFl();
  fscmFWA = fscmTFParseDataFscmFFl();
}
void fscmTFDataToSendToFscmF() {
  fscmTFSendDataFscmFBl(fscmRequestHomeSet);
  fscmTFSendDataFscmFBy(fscmTETVal);//enable
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
