#include <Wire.h>
int16_t cfAX, cfAY, cfAZ, cfGX, cfGY, cfGZ = 0;
double GDSX, GDSY, GDSZ = 0.0000;
double fscmCRoll = 0.0000;
double fscmCPitch = 0.0000;
long GX0 = -80;
long GY0 = 35;
long GZ0 = -35;
boolean fscmCEnabled = false;
unsigned long lastRecievedFscmF = 0;
float fscmFHeading, fscmFPitch, fscmFRoll = 0.000;
boolean fscmHomeSet = false;
unsigned long lastCalcedGyro = 0;
boolean justRecvdFscmF=false;
