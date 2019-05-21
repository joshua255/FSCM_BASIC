Client s;
//fscmdHeadingDistanceDisplay HDD;
fscmdMapDisplay MD;
fscmdOrientationDisplay OTD;
fscmdMiBarGraphDisplay MBGBOO;
fscmdMiBarGraphDisplay MBGBOA;
fscmdMiBarGraphDisplay MBGBOG;
fscmdMiBarGraphDisplay MBGBOM;
fscmdPowerGraphDisplay PWG;
fscmdCoBarGraphDisplay PWRCBG;
fscmdCoBarGraphDisplay FSCMDRSSI;
fscmdCoBarGraphDisplay TRANSRSSI;
fscmdCoBarGraphDisplay TBATCGD;
fscmdButton BSH;
fscmdMapStatus MS;
//////////////////constants to pass in/////////////////////////////////////////////////////
float maxDispFlyDistMeters=1000;
float WARNINGALT=0;
//////////////////recieved data////////////////////////////////////////////////////////////
////////////////////////////////recieve
boolean fscmHomeSet=false;
int fscmFOriSystemCal=0;
int fscmFOriGyroCal=0;
int fscmFOriAccelCal=0;
int fscmFOriMagCal=0;
float fscmFGpsLon=-123.0000;
float fscmFGpsLat=43.0000;
float fscmFGpsSatStat=0;
float fscmFGpsSpeed=0.00;
float fscmFGpsHeading=0.00;
int fscmFDistMeters=0;
float fscmFHeadFmHome=0;
float fscmFOriQuatX=0.000;
float fscmFOriQuatY=0.000;
float fscmFOriQuatZ=0.000;
float fscmFOriQuatW=0.000;
float fscmFGAlt=0.00;
float fscmFBatVolt=0.0;
int fscmFSigStrengthOfTran=10;
int fscmTSigStrengthFromF=10;
float fscmTBatVVal=0.00;
int fscmTRJXBVal=0;
int fscmTRJYBVal=0;
int fscmTLJXBVal=0;
int fscmTLJYBVal=0;
int fscmTLKBVal=0;
int fscmTRKBVal=0;
boolean fscmTLTVal=false;
boolean fscmTRTVal=false;
boolean fscmTLBVal=false;
boolean fscmTRBVal=false;
boolean fscmTETVal=false;
int fscmFConnTime=0;
float fscmCPitch=0.000;
float fscmCRoll=0.000;
//////////////////////////////setsometimes
float fscmHomeHeading = 0.000;
float fscmHomeLat = 0.00000;
float fscmHomeLon = 0.00000;
/////////////////////////////fscmDVars
boolean setHome=false;
int numWarnings=1;
int warningID=1;
long lastwarnedbattery=0;
long lastWarned=0;
boolean altwarningsilenced=false;
///////////////////////////values to send
////////////////////////////////////////////////////////////////////////////////////
void setup() {
  noSmooth();
  frameRate(10);
  size(1350, 700, P2D);//P2D is important
  background(0);
  stroke(255);
  textSize(40);
  text("loading FSCMd...", width*.4, height*.4);
  s=new Client(this, "localhost", 12340);
  setupPoints();
  MD=new fscmdMapDisplay(173, 225, 475, maxDispFlyDistMeters);
  MS=new fscmdMapStatus(0, 75, 171, 175);
  // HDD=new fscmdHeadingDistanceDisplay(200, 150, 120, maxDispFlyDistMeters);
  OTD=new fscmdOrientationDisplay(650, 0, 700, maxDispFlyDistMeters);
  MBGBOO=new fscmdMiBarGraphDisplay(0, 0, 50, 3, "orientation status");
  MBGBOA=new fscmdMiBarGraphDisplay(50, 0, 35, 3, "BNO055 accel status");
  MBGBOG=new fscmdMiBarGraphDisplay(85, 0, 35, 3, "BNO055 gyro status");
  MBGBOM=new fscmdMiBarGraphDisplay(120, 0, 35, 3, "BNO055 mag status");
  PWG=new fscmdPowerGraphDisplay(375, 0, 272, 100, 3.0, 4.2, 3000);
  PWRCBG=new fscmdCoBarGraphDisplay(PWG.posx-51, PWG.posy, PWG.sizey, 50, PWG.minval, PWG.maxval, 3.3, "BAT V");
  FSCMDRSSI=new fscmdCoBarGraphDisplay(160, 2, 50, 50, -100, -15, -80, "FSCM");
  TRANSRSSI=new fscmdCoBarGraphDisplay(210, 2, 50, 50, -100, -15, -80, "Trans");
  //  TBATCGD=new fscmdCoBarGraphDisplay(370, 0, 80, 3.3, 6, 3.5, "T Bat");
  BSH=new fscmdButton(267, 5, 51, color(0, 150, 0), true, "set home");
  fscmdSetupFscmTComms();//nothing needs to be called in draw()
  s.write("f s c m starting,#");
}
void draw() {
  fscmFEul=fscmdQuaternionToEuler(fscmFOriQuatX, fscmFOriQuatY, fscmFOriQuatZ, fscmFOriQuatW);
  setHome=BSH.display(setHome);
  fscmdHomeSet();
  runWarnings();
  //HDD.display(fscmHomeHeading, fscmFHeadFmHome, fscmFDistMeters, fscmFEul[0], fscmFGpsHeading); //float DHomeHeading, float DHeadingFromHome, float DDistMeters, float DDOFHeading, float DGPSHeading
  OTD.display(fscmFOriQuatW, fscmFOriQuatX, fscmFOriQuatY, fscmFOriQuatZ, fscmFGpsHeading, fscmFGAlt, fscmHomeHeading, fscmFHeadFmHome, fscmFDistMeters); //float Oriqw, float Oriqx, float Oriqy, float Oriqz, float GpsHeading, float CGAltitude, float DHomeHeading, float DHeadingFromHome, float DDistMeters
  String[] dispMsg={
    "home set", 
    "home lat", 
    "home lon", 
    "home heading", 
    "latitude", 
    "longitude", 
    "gps sat stat", 
    "gps ground speed", 
    "gps heading", 
    "heading", 
    "pitch", 
    "roll", 
    "distance", 
    "head from home", 
    "head to home diff", 
    "quaternion X", 
    "quaternion Y", 
    "quaternion Z", 
    "quaternion W", 
    "altitude", 
    "F bat voltage", 
    "T bat voltage", 
    "trans sig strength", 
    "fscmF sig strength", 
    "fscmC Pitch", 
    "fscmC Roll"
  };
  float[] dispVal={
    int(fscmHomeSet), 
    fscmHomeLat, 
    fscmHomeLon, 
    fscmHomeHeading, 
    fscmFGpsLon, 
    fscmFGpsLat, 
    fscmFGpsSatStat, 
    fscmFGpsSpeed, 
    fscmFGpsHeading, 
    fscmFEul[0], 
    fscmFEul[1], 
    fscmFEul[2], 
    fscmFDistMeters, 
    fscmFHeadFmHome, 
    (fscmFHeadFmHome-fscmFEul[0]-180)<=-180?360+(fscmFHeadFmHome-fscmFEul[0]-180):(fscmFHeadFmHome-fscmFEul[0]-180), 
    fscmFOriQuatX, 
    fscmFOriQuatY, 
    fscmFOriQuatZ, 
    fscmFOriQuatW, 
    fscmFGAlt, 
    fscmFBatVolt, 
    fscmTBatVVal, 
    fscmFSigStrengthOfTran, 
    fscmTSigStrengthFromF, 
    fscmCPitch, 
    fscmCRoll
  };
  fscmdDisplayInfo(dispMsg, dispVal, 0, 250, 170, 450, 10);
  MBGBOO.display(fscmFOriSystemCal);
  MBGBOA.display(fscmFOriAccelCal);
  MBGBOG.display(fscmFOriGyroCal);
  MBGBOM.display(fscmFOriMagCal);
  MS.display(points);
  MD.display(fscmFGpsLat, fscmFGpsLon, fscmHomeHeading, fscmFEul[0], fscmFGpsHeading, fscmHomeLat, fscmHomeLon);
  //  TBATCGD.display(fscmTBatVVal);
  PWG.display(fscmFBatVolt);
  PWRCBG.display(fscmFBatVolt);
  FSCMDRSSI.display(fscmFSigStrengthOfTran);
  TRANSRSSI.display(fscmTSigStrengthFromF);
  mousePushed=false;
  keyPushed=false;
}
void fscmdDataToParseFromFscmT() {
  fscmHomeSet=fscmdParseFscmTBl();
  fscmFOriSystemCal=fscmdParseFscmTIn();
  fscmFOriGyroCal=fscmdParseFscmTIn();
  fscmFOriAccelCal=fscmdParseFscmTIn();
  fscmFOriMagCal=fscmdParseFscmTIn();
  fscmFGpsLon=fscmdParseFscmTFl();
  fscmFGpsLat=fscmdParseFscmTFl();
  fscmFGpsSatStat=fscmdParseFscmTFl();
  fscmFGpsSpeed=fscmdParseFscmTFl();
  fscmFGpsHeading=fscmdParseFscmTFl();
  fscmFDistMeters=fscmdParseFscmTIn();
  fscmFHeadFmHome=fscmdParseFscmTFl();
  fscmFOriQuatX=fscmdParseFscmTFl();
  fscmFOriQuatY=fscmdParseFscmTFl();
  fscmFOriQuatZ=fscmdParseFscmTFl();
  fscmFOriQuatW=fscmdParseFscmTFl();
  fscmFGAlt=fscmdParseFscmTFl();
  fscmFBatVolt=fscmdParseFscmTFl();
  fscmFSigStrengthOfTran=fscmdParseFscmTIn();
  fscmTSigStrengthFromF=fscmdParseFscmTIn();
  fscmTBatVVal=fscmdParseFscmTFl();
  fscmTRJXBVal=fscmdParseFscmTIn();
  fscmTRJYBVal=fscmdParseFscmTIn();
  fscmTLJXBVal=fscmdParseFscmTIn();
  fscmTLJYBVal=fscmdParseFscmTIn();
  fscmTLKBVal=fscmdParseFscmTIn();
  fscmTRKBVal=fscmdParseFscmTIn();
  fscmTLTVal=fscmdParseFscmTBl();
  fscmTRTVal=fscmdParseFscmTBl();
  fscmTLBVal=fscmdParseFscmTBl();
  fscmTRBVal=fscmdParseFscmTBl();
  fscmTETVal=fscmdParseFscmTBl();
  fscmFConnTime=fscmdParseFscmTIn();
  fscmCPitch=fscmdParseFscmTFl();
  fscmCRoll=fscmdParseFscmTFl();
}
void fscmdDataToSendToFscmT() {
  fscmdSendDataFscmTBl(setHome);
  fscmdSendDataFscmTBl(numWarnings>0);
}
void runWarnings() {
  numWarnings=0;
  if (abs(fscmFEul[2])>90) {
    numWarnings++;
  }
  if (fscmFGAlt<=WARNINGALT) {
    numWarnings++;
  } else {
    altwarningsilenced=false;
  }
  if (fscmFConnTime>1000) {
    numWarnings++;
  }
  if (millis()-lastwarnedbattery>30000||(millis()-lastwarnedbattery>10000&&fscmFBatVolt<3.4)) {
    numWarnings++;
  }
  if (fscmTLTVal&&numWarnings==0) {
    if ((frameCount-lastWarned)/frameRate>10||((frameCount-lastWarned)/frameRate>1&&s.available()>0)) {
      lastWarned=frameCount;
      if (fscmTLKBVal>=0&&fscmTLKBVal<30) {
        if (fscmTLBVal||warningID!=-1) {
          s.write("compass heading"+",#");
        } else {
          s.write(nf(int(fscmFEul[0]))+",#");
        }
        warningID=-1;
      } else if (fscmTLKBVal>=30&&fscmTLKBVal<60) {
        if (fscmTLBVal||warningID!=-2) {
          s.write("g p s heading"+",#");
        } else {
          s.write(nf(int(fscmFGpsHeading))+",#");
        }
        warningID=-2;
      } else if (fscmTLKBVal>=60&&fscmTLKBVal<90) {
        if (fscmTLBVal||warningID!=-3) {
          s.write("altimeter reading"+",#");
        } else {
          s.write(nf(fscmFGAlt, 3, 1)+",#");
        }
        warningID=-3;
      } else if (fscmTLKBVal>=90&&fscmTLKBVal<120) {
        if (fscmTLBVal||warningID!=-4) {
          s.write("distance"+",#");
        } else {
          s.write(nf(fscmFDistMeters)+",#");
        }
        warningID=-4;
      } else if (fscmTLKBVal>=120&&fscmTLKBVal<150) {
        if (fscmTLBVal||warningID!=-5) {
          s.write("relative heading from home"+",#");
        } else {
          s.write(nf(int((fscmFHeadFmHome-fscmHomeHeading-180)<=-180?360+(fscmFHeadFmHome-fscmHomeHeading-180):(fscmFHeadFmHome-fscmHomeHeading-180)))+",#");
        }
        warningID=-5;
      } else if (fscmTLKBVal>=150&&fscmTLKBVal<180) {
        if (fscmTLBVal||warningID!=-6) {
          s.write("heading to home diff"+",#");
        } else {
          s.write(nf(int((fscmFHeadFmHome-fscmFEul[0]-180)<=-180?360+(fscmFHeadFmHome-fscmFEul[0]-180):(fscmFHeadFmHome-fscmFEul[0]-180)))+",#");
        }
        warningID=-6;
      } else if (fscmTLKBVal>=180&&fscmTLKBVal<210) {
        if (fscmTLBVal||warningID!=-7) {
          s.write("gps speed"+",#");
        } else {
          s.write(nf(fscmFGpsSpeed, 3, 1)+",#");
        }
        warningID=-7;
      } else if (fscmTLKBVal>=210&&fscmTLKBVal<240) {
        if (fscmTLBVal||warningID!=-7) {
          s.write("battery voltage"+",#");
        } else {
          s.write(nf(fscmFBatVolt, 1, 1)+",#");
        }
        warningID=-7;
      } else if (fscmTLKBVal>=240&&fscmTLKBVal<256) {
        if (fscmTLBVal||warningID!=-8) {
          //          s.write("name"+",#");
        } else {
          //          s.write(nf(int(number))+",#");
        }
        warningID=-8;
      }
      s.clear();
    }
  } else {//auto warnings
    if ((frameCount%int(frameRate*10)==0||s.available()>0)&&numWarnings>0) {
      if (warningID>4||warningID<=0) {//change as necessary
        warningID=1;
      }
      if (warningID==1) {
        if (abs(fscmFEul[2])>90) {
          s.write("inverted"+",#");
          s.clear();
        }
      } else if (warningID==2) {
        if (fscmFGAlt<=WARNINGALT) {
          if (!altwarningsilenced) {
            if (fscmTLBVal) {
              altwarningsilenced=true;
              s.write("silencing low altitude warnings,#");
            } else {
              s.write("low alt "+nf(fscmFGAlt, 3, 1)+",#");
            }
          } else {
            s.write(",#");
          }
          s.clear();
        }
      } else if (warningID==3) {
        if (fscmFConnTime>1000) {
          s.write("signal lost"+",#");
          s.clear();
        }
      } else if (warningID==4) {
        if (millis()-lastwarnedbattery>30000||(millis()-lastwarnedbattery>10000&&fscmFBatVolt<3.4)) {
          lastwarnedbattery=millis();
          s.write("battery voltage "+nf(fscmFBatVolt, 1, 1)+",#");
          s.clear();
        }
      }
      warningID++;
    }
  }
}
