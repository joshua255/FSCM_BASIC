void fscmFFWaypoints() {
  if (pointsWNum == 0) {
    numWayPoints = 0;
    fscmFWPI = 0;
  }
  if (pointsWI <= pointsWNum + 100 && pointsWI > 100) {
    numWayPoints = pointsWNum;
    waypoints[0][pointsWI - 101] = pointsWLat;
    waypoints[1][pointsWI - 101] = pointsWLon;
    waypoints[2][pointsWI - 101] = pointsWAlt;
    fscmFWPI = 1;
  } else {
    if (numWayPoints > 0) {
      fscmFWD = TinyGPSPlus::distanceBetween(gps.location.lat(), gps.location.lng(), waypoints[0][fscmFWPI - 1], waypoints[1][fscmFWPI - 1]);
      fscmFWH = TinyGPSPlus::courseTo(gps.location.lat(), gps.location.lng(), waypoints[0][fscmFWPI - 1], waypoints[1][fscmFWPI - 1]);
      fscmFWA = waypoints[2][fscmFWPI] - fscmFGAlt;
      if (fscmFWD < WAYPOINT_CLOSE_ENOUGH_DIST) {
        fscmFWPI++;
        if (fscmFWPI > numWayPoints) {
          fscmFWPI = 0;
        }
      }
    } else {
      fscmFWPI = 0;
      fscmFWD = 0;
      fscmFWH = 0;
      fscmFWA = 0;
    }
  }
}
void fscmdQuaternionToEulerSet(float qx, float qy, float qz, float qw) {
  fscmFHeading = 90 - degrees(atan2(2.0 * (qx * qy + qz * qw), (qx * qx - qy * qy - qz * qz + qw * qw)));
  fscmFHeading += MAGNETIC_VARIATION;
  if (fscmFHeading < 0) {
    fscmFHeading += 360;
  }
  Serial.println(fscmFHeading);
  fscmFPitch = -degrees(asin(-2.0 * (qx * qz - qy * qw) / (qx * qx + qy * qy + qz * qz + qw * qw)));
  fscmFRoll = degrees(atan2(2.0 * (qy * qz + qx * qw), (-qx * qx - qy * qy + qz * qz + qw * qw)));
}
void fscmFFCoproc() {
  if (digitalRead(8) == HIGH && Serial2.available()) {
    fscmFFDataToParseFromFscmC();
  }
  pinMode(12, OUTPUT);
  digitalWrite(12, LOW);
  fscmFFDataToSendToFscmC();
  Serial2.flush();
  lastSentFscmCMillis = millis();
  digitalWrite(12, HIGH);
  pinMode(12, INPUT_PULLUP);
}
boolean fscmFFParseDataFscmCBl() {
  byte msg = Serial2.read();
  if (msg == '0') {
    return false;
  }
  if (msg == '1') {
    return true;
  }
  return false;
}
byte fscmFFParseDataFscmCBy() {
  byte msg = Serial2.read();
  return msg;
}
int fscmFFParseDataFscmCIn() {
  union {
    byte b[2];
    int v;
  } d;
  d.b[0] = Serial2.read();
  d.b[1] = Serial2.read();
  return d.v;
}
float fscmFFParseDataFscmCFl() {
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
void fscmFFSendDataFscmCBy(byte val) {
  Serial2.write(val);
}
void fscmFFSendDataFscmCIn(int val) {
  union {
    byte b[2];
    int v;
  } d;
  d.v = val;
  Serial2.write(d.b[0]);
  Serial2.write(d.b[1]);
}
void fscmFFSendDataFscmCFl(float val) {
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
void fscmFFSendDataFscmCBl(boolean val) {
  Serial2.print(val);
}
void fscmFFReadSensors() {
  readBnoic();
  fscmFAltiVal = fscmFFCalcAltiVal();
  fscmFBatVolt = analogRead(9) * 3.3 * 2 / 1023;
  while (Serial1.available() > 0) {
    if (gps.encode(Serial1.read())) {
      fscmFGpsLon = gps.location.lng();
      fscmFGpsLat = gps.location.lat();
      fscmFGpsAlt = gps.altitude.meters();
      fscmFGpsSatStat = gps.satellites.value();
      fscmFGpsSpeed = gps.speed.mps();
      fscmFGpsHeading = gps.course.deg();
      fscmFDistMeters = TinyGPSPlus::distanceBetween(fscmHomeLat, fscmHomeLon, gps.location.lat(), gps.location.lng());
      fscmFHeadFmHome = TinyGPSPlus::courseTo(fscmHomeLat, fscmHomeLon, gps.location.lat(), gps.location.lng());
    }
  }
}
void fscmFFRadio() {
  uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
  uint8_t len = sizeof(buf);
  uint8_t data[fscmFRI];

  rf95.waitPacketSent();
  gotFscmTMsgLast = false;
  if (rf95.recv(buf, &len)) {
    fscmFLastRecvMillis = millis();
    fscmFLastSentCallFscmT = millis();
    gotFscmTMsgLast = true;
    for (int i = 0; i < len; i++) {
      fscmFRBuf[i] = buf[i];
    }
    fscmFRI = 0;
    fscmFSigStrengthOfTran = rf95.lastRssi();
    fscmFFDataToParseFromFscmT();
    fscmFRI = 0;
    fscmFFDataToSendToFscmT();
    for (int i = 0; i < fscmFRI; i++) {
      data[i] = fscmFRBuf[i];
    }
    rf95.send(data, sizeof(data));
  }  else if (millis() - fscmFLastSentCallFscmT > 750) {
    fscmFLastSentCallFscmT = millis();
    fscmFRI = 0;
    fscmFFDataToSendToFscmT();
    uint8_t data[fscmFRI];
    for (int i = 0; i < fscmFRI; i++) {
      data[i] = fscmFRBuf[i];
    }
    rf95.send(data, sizeof(data));
  }
}
void fscmFFSendDataFscmTBl(boolean val) {
  fscmFRBuf[fscmFRI] = val;
  fscmFRI++;
}
void fscmFFSendDataFscmTBy(byte val) {
  fscmFRBuf[fscmFRI] = val;
  fscmFRI++;
}
void fscmFFSendDataFscmTIn(int val) {
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
void fscmFFSendDataFscmTFl(float val) {
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
boolean fscmFFParseDataFscmTBl() {
  fscmFRI++;
  return  fscmFRBuf[fscmFRI - 1];
}
byte fscmFFParseDataFscmTBy() {
  fscmFRI++;
  return fscmFRBuf[fscmFRI - 1];
}
int fscmFFParseDataFscmTIn() {
  union {
    int v;
    byte b[2];
  } d;
  d.b[0] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  d.b[1] = fscmFRBuf[fscmFRI];
  fscmFRI++;
  return d.v;
}
float fscmFFParseDataFscmTFl() {
  union {
    float v;
    byte b[4];
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

void fscmFFHomeSet() {
  fscmHomeSet = false;
  if (fscmRequestHomeSet) {
    fscmHomeSet = true;
    fscmHomeLat = fscmFGpsLat;
    fscmHomeLon = fscmFGpsLon;
    fscmHomeAlt = fscmFAltiVal;//could be improved by including gps
  }
}
float fscmFFAltCalc() {
  //can be improved with gps and possible sonar
  fscmFGAlt = fscmFAltiVal - fscmHomeAlt;
}
void fscmFFSetupSensors() {
  Wire.begin();
  Serial1.begin(9600);//for gps
  delay(10);
  Serial1.println("$PMTK220,1000*1F");
  Serial1.println("$PMTK300,1000,0,0,0,0*1C");
  Serial1.println("$PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*28");//PMTK_SET_NMEA_OUTPUT_RMCGGA);
  Serial1.println("$PMTK251,57600*2C");//PMTK_SET_BAUD_57600
  Serial1.flush();
  Serial1.begin(57600);
  delay(10);
  alt.begin();
  //setup bno
  Wire.beginTransmission(0x28);//address, operation mode, NDOF
  Wire.write(0x3D);
  Wire.write(0x0C);
  Wire.endTransmission(true);
}
void fscmFFSetupCoproc() {
  Serial2.begin(250000);
  pinPeripheral(10, PIO_SERCOM);
  pinPeripheral(11, PIO_SERCOM);
}
void fscmFFSetupRadio() {
  if (!rf95.init()) {
    while (1);
  }
  rf95.setFrequency(RF95_FREQ);
  rf95.setTxPower(23, false);
}
float fscmFFCalcAltiVal() {
  fscmFAltArrayVar[fscmFAltArrayI] = alt.readPressure();
  fscmFAltArrayI++;
  if (fscmFAltArrayI >= sizeof(fscmFAltArrayVar) / 4) {
    fscmFAltArrayI = 0;
  }
  long altAVARS = 0;
  for (int i = 0; i < sizeof(fscmFAltArrayVar) / 4; i++) {
    altAVARS += fscmFAltArrayVar[i];
  }
  return 44330.00 * (1.0 - pow(((float)altAVARS / (sizeof(fscmFAltArrayVar) / 4)) / 1013250, 0.1903));
}
void readBnoic() {
  uint8_t buffer[8];
  memset (buffer, 0, 8);
  int16_t x, y, z, w;
  Wire.beginTransmission(0x28);
  Wire.write(0x20);
  Wire.endTransmission();
  Wire.requestFrom(0x28, 8);
  for (uint8_t i = 0; i < 8; i++) {
    buffer[i] = Wire.read();
  }
  w = (((uint16_t)buffer[1]) << 8) | ((uint16_t)buffer[0]);
  x = (((uint16_t)buffer[3]) << 8) | ((uint16_t)buffer[2]);
  y = (((uint16_t)buffer[5]) << 8) | ((uint16_t)buffer[4]);
  z = (((uint16_t)buffer[7]) << 8) | ((uint16_t)buffer[6]);
  const float scale = (1.0 / (1 << 14));
  fscmFOriQuatW = w * scale;
  fscmFOriQuatX = x * scale;
  fscmFOriQuatY = y * scale;
  fscmFOriQuatZ = z * scale;
  Wire.beginTransmission(0x28);
  Wire.write(0x35);//BNO055_CALIB_STAT_ADDR
  Wire.endTransmission();
  Wire.requestFrom(0x28, 1);
  uint8_t calData = Wire.read();
  fscmFOriSystemCal = (calData >> 6) & 0x03;
  fscmFOriGyroCal = (calData >> 4) & 0x03;
  fscmFOriAccelCal = (calData >> 2) & 0x03;
  fscmFOriMagCal = calData & 0x03;
  fscmdQuaternionToEulerSet(fscmFOriQuatX, fscmFOriQuatY, fscmFOriQuatZ, fscmFOriQuatW);
}
