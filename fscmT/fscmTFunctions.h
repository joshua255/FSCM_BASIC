#include "FastLED.h"
#include <SPI.h>
#include <RH_RF95.h>
#define RF95_FREQ 905
#define RFM95_CS      8
#define RFM95_INT     7
RH_RF95 rf95(RFM95_CS, RFM95_INT);
#define LJXPin A1
#define LJYPin A2
#define RJXPin A0
#define RJYPin A3
#define LKPin A5
#define RKPin A4
#define LEDPin 13
#define RTPin 11
#define LTPin 12
#define ETPin 10
#define TBATMPin 9
#define RBPin 5
#define LBPin 6
CRGB ledCA[10];
#define ledStatOneID 5
#define ledStatTwoID 4
#define ledLeftID 9
#define ledRightID 8
#define ledConnID 6
#define ledBatStatBotID 3
#define ledBatStatMidID 2
#define ledBatStatTopID 1
#define ledTranBatStatID 0
#define ledTogLightID 7
////////////////////////////////////////fscmTVals
byte fscmTLJXBVal = 0;
byte fscmTLJYBVal = 0;
byte fscmTRJXBVal = 0;
byte fscmTRJYBVal = 0;
byte fscmTLKBVal = 0;
byte fscmTRKBVal = 0;
int fscmTLJXIVal = 0;
int fscmTLJYIVal = 0;
int fscmTRJXIVal = 0;
int fscmTRJYIVal = 0;
int fscmTLKIVal = 0;
int fscmTRKIVal = 0;
boolean fscmTRTVal = false;
boolean fscmTLTVal = false;
boolean fscmTETVal = false;
boolean fscmTRBVal = false;
boolean fscmTLBVal = false;
float fscmTBatVVal = 0.000;
unsigned long fscmTLastMillisSentFscmD = 0;
unsigned long fscmTLastMillisTransFscmF = 0;
unsigned long fscmTLastMillisRecvFscmF = 0;
boolean fscmTReadyToSendToFscmD = false;
boolean fscmTRecvdFscmFNew = false;
uint8_t fscmFRBuf[RH_RF95_MAX_MESSAGE_LEN];
byte fscmFRI = 0;
int fscmFAltArrayVar[20];
byte fscmFAltArrayI = 0;
int fscmTSigStrengthFromF = 10;
float fscmCPitch = 0.000;
float fscmCRoll = 0.000;
float fscmFWH = 0.00;
float fscmFWD = 0.00;
float fscmFWA = 0.00;
//////////////////////////////////////////////recieve from fscmF
boolean fscmHomeSet = false;
uint8_t fscmFOriSystemCal, fscmFOriGyroCal, fscmFOriAccelCal, fscmFOriMagCal = 0;
float fscmFGpsLon = -100.0000;
float fscmFGpsLat = 40.0000;
byte fscmFGpsSatStat = 0;
float fscmFGpsSpeed = 0;
float fscmFGpsHeading = 0;
int fscmFDistMeters = 10;
float fscmFHeadFmHome = 0;
float fscmFOriQuatX, fscmFOriQuatY, fscmFOriQuatZ, fscmFOriQuatW = 0.0000;
float fscmFGAlt = 1;
float fscmFBatVolt = 1;
int fscmFSigStrengthOfTran = 10;
byte fscmFWPI = 0;
/////////////////////////////recieve from fscmD
boolean fscmRequestHomeSet = false;
boolean fscmDWarnings = false;
byte pointsWNum = 0;
byte pointsWI = 0;
float pointsWLon = 0.00;
float pointsWLat = 0.00;
float pointsWAlt = 0.00;
float WaypointCloseEnoughDist = 10.00;
