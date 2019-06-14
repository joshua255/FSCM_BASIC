#include <Arduino.h>   // required before wiring_private.h
#include "wiring_private.h" // pinPeripheral() function
#include <Wire.h>
#include <SPI.h>
#include <RH_RF95.h>
#define RF95_FREQ 905
#define RFM95_CS     8
#define RFM95_INT    3
RH_RF95 rf95(RFM95_CS, RFM95_INT);
#include <Adafruit_BMP280.h>
#include <TinyGPS++.h>
Adafruit_BMP280 alt;
TinyGPSPlus gps;
Uart Serial2 (&sercom1, 11, 10, SERCOM_RX_PAD_0, UART_TX_PAD_2);
void SERCOM1_Handler()
{
  Serial2.IrqHandler();
}
/////////////////////////////////////////fscmF internal
boolean fscmFEnabled = false;
float WAYPOINT_CLOSE_ENOUGH_DIST = 10.0;
float MAGNETIC_VARIATION = 15.0; //degrees
uint8_t fscmFRBuf[RH_RF95_MAX_MESSAGE_LEN];
uint8_t fscmFRLen = 0;
byte fscmFRI = 0;
int fscmFAltArrayVar[35];
byte fscmFAltArrayI = 0;
unsigned long fscmFLastRecvMillis = 0;
unsigned long fscmFLastSentCallFscmT = 0;
unsigned long lastSentFscmCMillis = 0;
boolean gotFscmTMsgLast = false;
float waypoints[3][25] = {0};

float fscmFGpsAlt = 0;
float fscmFAltiVal = 0;

float fscmHomeLat = 45;
float fscmHomeLon = -100;
float fscmHomeAlt = 15000;
float fscmHomeHeading = 0;
////////////////////////////////////////fscmF to send
float fscmFHeading, fscmFPitch, fscmFRoll = 0.000;
boolean fscmHomeSet = false;
uint8_t fscmFOriSystemCal, fscmFOriGyroCal, fscmFOriAccelCal, fscmFOriMagCal = 0;
float fscmFGpsLon = 0.0000;
float fscmFGpsLat = 0.0000;
float fscmFGpsSatStat = 0;
float fscmFGpsSpeed = 0;
float fscmFGpsHeading = 0;
int fscmFDistMeters = 10;
float fscmFHeadFmHome = 0;
float fscmFOriQuatX, fscmFOriQuatY, fscmFOriQuatZ, fscmFOriQuatW = 0.0000;
float fscmFGAlt = 1;
float fscmFBatVolt = 5;
int fscmFSigStrengthOfTran = 10;
float fscmCPitch = 0.000;
float fscmCRoll = 0.000;
byte fscmFWPI = 0;
float fscmFWH = 0.00;
float fscmFWD = 0.00;
float fscmFWA = 0.00;
////////////////////////////////////////recieve from fscmT
boolean fscmRequestHomeSet = false;
byte jrx = 0;
byte jry = 0;
byte jlx = 0;
byte jly = 0;
byte lk = 0;
byte rk = 0;
boolean lt = false;
boolean rt = false;
byte pointsWNum = 0;
byte numWayPoints = 0;
byte pointsWI = 0;
float pointsWLon = 0;
float pointsWLat = 0;
float pointsWAlt = 0;
