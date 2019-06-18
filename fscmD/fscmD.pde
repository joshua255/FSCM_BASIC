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
fscmdButton TLB;
fscmdButton SWPB;
fscmdButton SPB;
fscmdButton LPB;
fscmdMapStatus MS;
fscmdSlider WPCEDS;
fscmdSlider WAS;
fscmdButton SSB;
fscmdButton LSB;
//////////////////constants to pass in/////////////////////////////////////////////////////
float maxDispFlyDistMeters=1000;
float WARNINGALT=0;
float WAYPOINT_CLOSE_ENOUGH_DIST=10.0;
float MAGNETIC_VARIATION=15.0;
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
byte fscmFWPI=0;
float fscmFWH=0.000;
float fscmFWD=0.000;
float fscmFWA=0.000;
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
boolean sendWPoints=false;
///////////////////////////values to send
byte pointsWNum=0;
byte pointsWI=0;
float pointsWLon=0.00;
float pointsWLat=0.00;
float pointsWAlt=0.00;
////////////////////////////////////////////////////////////////////////////////////
void setup() {
  noSmooth();
  frameRate(16);
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
  FSCMDRSSI=new fscmdCoBarGraphDisplay(160, 2, 50, 50, -110, -35, -95, "FSCM");
  TRANSRSSI=new fscmdCoBarGraphDisplay(210, 2, 50, 50, -110, -35, -95, "Trans");
  //  TBATCGD=new fscmdCoBarGraphDisplay(370, 0, 80, 3.3, 6, 3.5, "T Bat");
  BSH=new fscmdButton(263, 2, 59, 49, color(0, 150, 0), true, "set home");
  TLB=new fscmdButton(277, 55, 45, 44, color(200, 150, 0), true, "logtel");
  SWPB=new fscmdButton(230, 55, 45, 44, color(255, 0, 255), true, "send points");
  SPB=new fscmdButton(173, 55, 55, 20, color(#FF00B7), true, "saveP");
  LPB=new fscmdButton(173, 79, 55, 20, color(#D400FF), true, "loadP");
  SSB=new fscmdButton(173, 103, 55, 20, color(#5AFF03), true, " sv set");
  LSB=new fscmdButton(173, 127, 55, 20, color(#03FF72), true, " ld set");
  WPCEDS=new fscmdSlider(243, 160, 20, color(255, 0, 255), "wpce", WAYPOINT_CLOSE_ENOUGH_DIST, 0, 30); //  fscmdSlider(float X, float Y, float W, color C, String T, float VAL, float MIN, float MAX) 
  WAS=new fscmdSlider(243, 172, 20, color(100, 20, 20), "wrnA", WARNINGALT, -2, 10);
  fscmdSetupFscmTComms();//nothing needs to be called in draw()
  s.write("f s c m starting,#");
}
void draw() {
  noStroke();
  fill(15);
  rect(170, 101, 480, 124);
  fscmFEul=fscmdQuaternionToEuler(fscmFOriQuatX, fscmFOriQuatY, fscmFOriQuatZ, fscmFOriQuatW);
  setHome=BSH.display(setHome);
  fscmDWaypointsSend();
  wastelogging=telogging;
  if (telogging&&wastelogging) {
    TLB.msg="rec...     "+telog.getRowCount();
  } else {
    TLB.msg="log tel";
  }
  telogging=TLB.display(telogging);
  SPB.display(false);
  LPB.display(false);
  if (SPB.jp) {
    fscmDSaveWaypoints();
  }
  if (LPB.jp) {
    fscmDLoadWaypoints();
  }
  SSB.display(false);
  LSB.display(false);
  if (SSB.jp) {
    String setfl[]=new String[10];
    setfl[1]=str(WARNINGALT);
    setfl[2]=str(WAYPOINT_CLOSE_ENOUGH_DIST);
    saveStrings("settings/settings.txt", setfl);
  }
  if (LSB.jp||frameCount==1) {
    try {
      String setfl[]=loadStrings("settings/settings.txt");
      WARNINGALT=float(setfl[1]);
      WAYPOINT_CLOSE_ENOUGH_DIST=float(setfl[2]);
    }
    catch(Exception e) {
      println("error loading settings");
    }
  }
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
    "fscmC Roll", 
    "fscmF Conn Time", 
    "fscmT Conn Time", 
    "fscmFWPI", 
    "fscmFWH", 
    "fscmFWD", 
    "fscmFWA", 
    "etv"
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
    fscmCRoll, 
    fscmFConnTime, 
    fscmDTConnTime, 
    fscmFWPI, 
    fscmFWH, 
    fscmFWD, 
    fscmFWA, 
    int(fscmTETVal)
  };
  fscmdDisplayInfo(dispMsg, dispVal, 0, 250, 170, 450, 10);
  MBGBOO.display(fscmFOriSystemCal);
  MBGBOA.display(fscmFOriAccelCal);
  MBGBOG.display(fscmFOriGyroCal);
  MBGBOM.display(fscmFOriMagCal);
  //  TBATCGD.display(fscmTBatVVal);
  MS.display(points);
  MD.display(fscmFGpsLat, fscmFGpsLon, fscmHomeHeading, fscmFEul[0], fscmFGpsHeading, fscmHomeLat, fscmHomeLon);
  PWG.display(fscmFBatVolt);
  PWRCBG.display(fscmFBatVolt);
  FSCMDRSSI.display(fscmFSigStrengthOfTran);
  TRANSRSSI.display(fscmTSigStrengthFromF);
  WARNINGALT=WAS.display(WARNINGALT);
  WAYPOINT_CLOSE_ENOUGH_DIST=WPCEDS.display(WAYPOINT_CLOSE_ENOUGH_DIST);
  runTelog();
  mousePushed=false;
  keyPushed=false;
  homeSet=false;
  fscmDJustGotTS=false;
  mouseDragged=false;
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
  fscmFWPI=fscmdParseFscmTBy();
  fscmFWH=fscmdParseFscmTFl();
  fscmFWD=fscmdParseFscmTFl();
}
void fscmdDataToSendToFscmT() {
  fscmdSendDataFscmTBl(setHome);
  fscmdSendDataFscmTBl(numWarnings>0);
  fscmdSendDataFscmTBy(pointsWNum);
  fscmdSendDataFscmTBy(pointsWI);
  fscmdSendDataFscmTFl(pointsWLon);
  fscmdSendDataFscmTFl(pointsWLat);
  fscmdSendDataFscmTFl(pointsWAlt);
  fscmdSendDataFscmTFl(WAYPOINT_CLOSE_ENOUGH_DIST);
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
        if (fscmTLBVal||warningID!=-8) {
          s.write("battery voltage"+",#");
        } else {
          s.write(nf(fscmFBatVolt, 1, 1)+",#");
        }
        warningID=-8;
      } else if (fscmTLKBVal>=240&&fscmTLKBVal<256) {
        if (fscmTLBVal||warningID!=-9) {
          s.write("waypoint"+",#");
        } else {
          if (fscmFWPI>0) {
            s.write(nf(int((540+fscmFWH-fscmFEul[0])%360-180))+" d "+int(fscmFWD)+" m"+",#");
          } else {
            s.write("no point,#");
          }
        }
        warningID=-9;
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
