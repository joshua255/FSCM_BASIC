#include "fscmCFunctions.h"
#include "fscmC.h"
void setup() {
  fscmCFSetupGyro();
  Serial2.begin(250000);//to fscmF
  //  Serial.begin(250000);//for DEBUG
  pinMode(13, OUTPUT);
  pinMode(8, INPUT_PULLUP);
  zeroGyro();
  pinMode(0, OUTPUT);
  pinMode(1, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(16, INPUT);
  pinMode(15, INPUT);
  pinMode(14, INPUT_PULLUP);
  attachInterrupt(14, selISRf, CHANGE);
  throttle.writeMicroseconds(1000);
}
void loop() {
  fscmCFReadGyro();
  fscmCFFscmFComms();
  if (fscmHomeSet) {
    zeroGyro();
  }
  busVoltage = busVoltage * .999 + .001 * analogRead(15) * busVoltsPerDAC;
  batVoltage = batVoltage * .999 + .001 * analogRead(16) * batVoltsPerDAC;
  receiverOffline = micros() - controlPinFallTime > controlTimeout;
  if (!receiverOffline) {
    if (micros() - controlPinRiseTime > 2500) {//outside pulse
      if (controlPinFallTime - controlPinRiseTime > controlThresh) {
        inControl = false;
      } else {
        inControl = true;
      }
    }
  } else {
    inControl = true;
  }

  if (millis() - lastRecievedFscmF < 1000) {
    if (fscmCEnabled) {
      digitalWrite(13, HIGH);
      //enabled
      if (!ailerons.attached()) {
        ailerons.attach(0);
      }
      if (!elevator.attached()) {
        elevator.attach(1);
      }
      if (!throttle.attached()) {
        throttle.attach(2);
      }
      if (!rudder.attached()) {
        rudder.attach(3);
      }
      ailerons.writeMicroseconds(map(jrx, 0, 255, 2000, 1000));
      elevator.writeMicroseconds(map(jry, 0, 255, 2000, 1000));
      smoothedThrottle += constrain((float)map(jly, 0, 255, 1000, 2000) - smoothedThrottle, -1.0, 1.0);
      throttle.writeMicroseconds(int(smoothedThrottle));
      rudder.writeMicroseconds(map(jlx, 0, 255, 1000, 2000));

    } else { //disabled
      digitalWrite(13, LOW);
      ///////////disabled
      ailerons.detach();
      elevator.detach();
      throttle.writeMicroseconds(1000);
      smoothedThrottle = 1000;
      rudder.detach();
    }
  }
  else {//lost connection
    digitalWrite(13, (millis() / 250) % 2);
    //lost connection (disable)
    smoothedThrottle = 1000;
    throttle.writeMicroseconds(1000);
  }
}

FASTRUN void selISRf(void) {
  if (digitalRead(14)) {
    controlPinRiseTime = micros();
  } else {
    controlPinFallTime = micros();
  }
}

void fscmCFDataToSendToFscmF() {
  fscmCFSendDataFscmFFl(fscmCPitch);
  fscmCFSendDataFscmFFl(fscmCRoll);
  fscmCFSendDataFscmFBl(inControl);
  fscmCFSendDataFscmFBl(receiverOffline);
  fscmCFSendDataFscmFFl(batVoltage);
  fscmCFSendDataFscmFFl(busVoltage);
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
