import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.mapdisplay.MapDisplayFactory;
import processing.net.*;
/////////////////////////////reusable functions for fscm************************************************************
float[] fscmFEul=new float[3];
int fscmdTSi=0;
String[] fscmdTSInfo;
String fscmdTSIn;
boolean fscmdTSGood=false;
boolean mousePushed=false;
boolean keyPushed=false;
import processing.serial.*;
Serial fscmTS;
class fscmdMapDisplay {
  int x;
  int y;
  int s;
  float maxDispFlyDistMeters;
  UnfoldingMap map;
  PGraphics mpg;
  fscmdMapDisplay(int X, int Y, int S, float MaxDispFlyDistMeters) {
    x=X;
    y=Y;
    s=S;
    maxDispFlyDistMeters=MaxDispFlyDistMeters;
    map = new UnfoldingMap(fscmD.this, x, y, s, s, new Microsoft.HybridProvider());
    map.setZoomRange(4, 18);
    map.zoomAndPanTo(10, new Location(44, -123));
    MapUtils.createDefaultEventDispatcher(fscmD.this, map);
  }
  void display(float FscmFGpsLat, float FscmFGpsLon, float DHomeHeading, float DDOFHeading, float DGPSHeading, float FscmHomeLat, float FscmHomeLon) {
    if (fscmHomeSet) {
      map.panTo(new Location(FscmHomeLat, FscmHomeLon));
    }
    map.rotateTo(-radians(DHomeHeading));
    map.draw();
    stroke(255);
    strokeWeight(1);
    pushMatrix(); 
    translate(x+s/2, y+s/2); 
    rotate(PI-radians(DHomeHeading)); 
    fill(155, 0, 0); 
    triangle(-s*.008, s*.45, s*.008, s*.45, 0, s*.49); //north
    popMatrix();
    mpg=createGraphics(s, s, P2D);
    mpg.beginDraw();
    marker(map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).x-x, map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).y-y, color(0, 255, 0), "home", "0", nf((360+DDOFHeading-fscmFHeadFmHome)%360-180, 3, 0), nf(fscmFDistMeters));
    circleLocRDm(new Location(FscmHomeLat, FscmHomeLon), maxDispFlyDistMeters/4, color(0, 200, 0));
    circleLocRDm(new Location(FscmHomeLat, FscmHomeLon), maxDispFlyDistMeters/2, color(200, 200, 0));
    circleLocRDm(new Location(FscmHomeLat, FscmHomeLon), maxDispFlyDistMeters, color(200, 0, 0));
    strokeWeight(2);
    stroke(0, 255, 0, 150);
    mpg.line(map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).x-x, map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).y-y, map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).x-x, map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).y-y);
    mpg.pushMatrix(); 
    mpg.translate(map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).x-x, map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).y-y);
    mpg.stroke(100, 255, 100);
    mpg.pushMatrix();
    mpg.strokeWeight(1);
    mpg.rotate(PI+radians(DDOFHeading-DHomeHeading)); 
    mpg.fill(255, 255, 255); 
    mpg.stroke(0);
    mpg.triangle(-s/75, 0, s/75, 0, 0, s/20);
    mpg.stroke(255, 255, 255, 180);
    mpg.strokeWeight(2);
    mpg.line(0, 0, 0, s);
    mpg.fill(255, 0, 0); 
    mpg.ellipse(0, 0, 6, 6);
    mpg.popMatrix();
    mpg.rotate(radians((DGPSHeading-DHomeHeading))); 
    mpg.strokeWeight(2); 
    mpg.stroke(0, 0, 255, 180); 
    mpg.line(0, 0, 0, s); //gps plane direction
    mpg.popMatrix();
    mpg.endDraw();
    image(mpg, x, y);
  }
  void circleLocRDm(Location Loc, float R, color C) {
    ScreenPosition pos = map.getScreenPosition(Loc);
    float r = getDistance(Loc, R);
    mpg.noFill();
    mpg.strokeWeight(1);
    mpg.stroke(C);
    mpg.ellipse(pos.x-x, pos.y-y, r*2, r*2);
  } 
  float getDistance(Location mainLocation, float mLength) {
    Location tempLocation = GeoUtils.getDestinationLocation(mainLocation, 90, mLength/1000.00);
    ScreenPosition pos1 = map.getScreenPosition(mainLocation);
    ScreenPosition pos2 = map.getScreenPosition(tempLocation);
    return dist(pos1.x, pos1.y, pos2.x, pos2.y);
  }
  void marker(float X, float Y, color C, String Name, String Alt, String Heading, String Distance) {
    mpg.strokeWeight(1);
    mpg.stroke(C);
    mpg.fill(C, 120);
    mpg.ellipse(X, Y, 10, 10);
    mpg.line(X+10, Y, X-10, Y);
    mpg.line(X, Y+10, X, Y-10);
    mpg.textSize(8);
    mpg.text(Alt, X+6, Y+6);
    mpg.text(Name, X-6-textWidth(Name), Y+6);
    mpg.text(Heading, X-6-textWidth(Heading), Y+9);
    mpg.text(Distance, X+6, Y+14);
  }
}
class fscmdButton {
  int x;
  int y;
  int s;
  color c;
  boolean l;
  String msg;
  boolean t=false;
  boolean lp=false;
  fscmdButton(int X, int Y, int S, color C, boolean L, String MSG) {
    x=X;
    y=Y;
    s=S;
    c=C;
    l=L;
    msg=MSG;
  }
  boolean display(boolean v) {
    t=v;
    strokeWeight(4);
    stroke(c);
    if (mouseX>x&&mouseX<x+s&&mouseY>y&&mouseY<y+s&&mousePressed) {
      stroke(red(c)/2, green(c)/2, blue(c));
      if (lp==false) {
        if (l) {
          t=!t;
        } else {
          t=true;
        }
      }
      lp=true;
    } else {
      if (!l) {
        t=false;
      }
      lp=false;
    }
    if (t) {
      fill(255);
    } else {
      fill(0);
    }
    rect(x, y, s, s);
    textSize(14);
    fill(155);
    text(msg, x, y+s/6, s, s);
    return t;
  }
}
void serialEvent(Serial fscmTS) {
  char readin=fscmTS.readChar();
  fscmdTSIn+=readin;
  if (readin=='<') {
    fscmdTSIn="";
    fscmdTSGood=true;
  }
  if (readin=='>'&&fscmdTSGood) {
    fscmdTSGood=false;
    fscmdTSInfo=split(fscmdTSIn, ',');
    fscmdTSi=0;
    fscmdDataToParseFromFscmT();
    fscmTS.write("<");
    fscmdDataToSendToFscmT();
    fscmTS.write(">");
  }
}
void fscmdSendDataFscmTBl(boolean d) {
  if (d) {
    fscmTS.write("1,");
  } else {
    fscmTS.write("0,");
  }
}
void fscmdSendDataFscmTIn(int d) {
  fscmTS.write(str(d));
  fscmTS.write(",");
}
void fscmdSendDataFscmTFl(float d) {
  fscmTS.write(str(d));
  fscmTS.write(",");
}
void fscmdSetupFscmTComms() {
  try {
    fscmTS=new Serial(this, Serial.list()[0], 2000000);
  }
  catch(Exception e) {
    println("no transmitter, stopping program!");
    while (true);
  }
}
void fscmdHomeSet() {
  if (fscmHomeSet==true) {
    fscmHomeHeading=fscmFEul[0];
    fscmHomeLat=fscmFGpsLat;
    fscmHomeLon=fscmFGpsLon;
    setHome=false;
  }
}
int fscmdParseFscmTIn() {
  fscmdTSi++;
  return int(fscmdTSInfo[fscmdTSi]);
}
float fscmdParseFscmTFl() {
  fscmdTSi++;
  return float(fscmdTSInfo[fscmdTSi]);
}
boolean fscmdParseFscmTBl() {
  fscmdTSi++;
  if (int(fscmdTSInfo[fscmdTSi])==0) {
    return false;
  } else {
    return true;
  }
}
float[] fscmdQuaternionToEuler(float qx, float qy, float qz, float qw) {
  float[] eul=new float[3];
  eul[0] = 90-degrees(atan2(2.0*(qx*qy+qz*qw), (qx*qx-qy*qy-qz*qz+qw*qw)));
  if (eul[0]<0) {
    eul[0]+=360;
  }
  eul[1] = -degrees(asin(-2.0*(qx*qz-qy*qw)/(qx*qx+qy*qy+qz*qz+qw*qw)));
  eul[2] = degrees(atan2(2.0*(qy*qz+qx*qw), (-qx*qx-qy*qy+qz*qz+qw*qw)));
  return eul;
}
void fscmdDisplayInfo(String[] msg, float[] val, int x, int y, int w, int h, int s) {
  textSize(s);
  stroke(255);
  strokeWeight(1);
  fill(10);
  rect(x, y, w, h);
  fill(255);
  for (int i=0; i<msg.length; i++) {
    text(msg[i], x+5, (i)*h/(msg.length+1)+y, w*.95, 2*h/(msg.length+1));
    text(": "+str(val[i]), x+5+ constrain(textWidth(": "+msg[i]), 0, w*.95), (i)*h/(msg.length+1)+y, w-x- textWidth(": "+msg[i]), 2*h/(msg.length+1));
  }
}
class fscmdCoBarGraphDisplay {
  int posx, posy, sizey, sizex;
  float minval, maxval;
  float warnval;
  float val;
  String msg;
  fscmdCoBarGraphDisplay(int Posx, int Posy, int Sizey, int Sizex, float Minval, float Maxval, float Warnval, String Msg) {
    posx=Posx;
    posy=Posy;
    sizey=Sizey;
    sizex=Sizex;
    minval=Minval;
    maxval=Maxval;
    warnval=Warnval;
    msg=Msg;
  }
  void display(float Val) {
    val=constrain(Val, minval, maxval);
    fill(255);
    strokeWeight(1);
    stroke(255);
    fill(0);
    rect(posx, posy, sizex, sizey);
    noStroke();
    colorMode(HSB);
    fill(map(val, minval, maxval, 0, 70), 255, 255);
    colorMode(RGB);
    rect(posx, posy+sizey, sizex, -map(val, minval, maxval, 0, sizey));
    fill(255);
    if (Val<warnval&&frameCount%15<3) {
      fill(255, 50, 50);
    }
    textSize(17);
    text(nf(Val), posx, posy, sizex, 28);
    textSize(14);
    fill(155);
    text(msg, posx+1, posy+sizey);
  }
}
class fscmdPowerGraphDisplay {
  int posx, posy, sizey, sizex, speedm;
  float maxval, minval;
  float val;
  int x=0;
  long lastMillis;
  fscmdPowerGraphDisplay(int Posx, int Posy, int Sizex, int Sizey, float Minval, float Maxval, int Speedm) {
    posx=Posx;
    posy=Posy;
    sizex=Sizex;
    sizey=Sizey;
    minval=Minval;
    maxval=Maxval;
    speedm=Speedm;
  }
  void display(float Val) {
    val=Val;
    if (abs(millis()-lastMillis)>=speedm) {
      lastMillis=millis();
      x++;
    }
    if (x>sizex||x<1) {
      x=1;
    }
    stroke(255);
    line(posx+x, posy, posx+x, posy+sizey);
    stroke(0);
    line(posx+x-1, posy, posx+x, posy+sizey);
    noFill();
    colorMode(HSB);
    stroke(map(val, minval, maxval, 0, 70), 255, 255);
    colorMode(RGB);
    line(x+posx-1, posy+sizey, x+posx-1, posy+sizey-constrain(map(val, minval, maxval, 0, sizey), 0, sizey));
    rect(posx, posy, sizex, sizey);
  }
}
class fscmdMiBarGraphDisplay {
  ///////////////setup vars
  int posx;
  int posy;
  int size;
  int nb;
  String msg; 
  ///////////////internal vars
  ///////////////display vars
  int num;
  fscmdMiBarGraphDisplay(int Posx, int Posy, int Size, int Nb, String Msg) {
    posx=Posx;
    posy=Posy;
    size=Size;
    nb=Nb;
    msg=Msg;
  }
  void display(int Num) {///num from 0 to nb
    num=constrain(Num, 0, nb);
    noStroke();
    colorMode(HSB);
    fill(map(num, 0, nb, 0, 50), 255, map(num, 0, nb, 255, 200));
    colorMode(RGB);
    if (num==nb) {
      fill(0);
    }
    rect(posx, posy, size, size);
    for (int i=1; i<=nb; i++) {
      if (i<=num) {//filled bar
        fill(255);
      } else {
        fill(0);
      }
      rect(posx+size/nb*(i-1)+size/5/nb, posy+size-size/4/nb, size/4/nb*3, -map(i, 1, nb, size/3, size-2*size/4/nb));
    }
    colorMode(HSB);
    fill(map(num, 0, nb, 0, 50), 255, map(num, 0, nb, 255, 200));
    colorMode(RGB);
    if (num==nb) {
      fill(0);
    }
    rect(posx, posy+size, size, size);
    fill(255);
    textSize(8);
    textLeading(10);
    text(msg, posx, posy+size, size, size);
  }
}
class fscmdOrientationDisplay {
  ////////////setup vars
  int posx; 
  int posy; 
  int size; 
  float maxDistMeters; 

  //////////internal vars
  int stgiRes=2500; 
  float landRat=4.0; 

  //////////updated vars
  float oriqw=1; 
  float oriqx=0; 
  float oriqy=0; 
  float oriqz=0; 
  float dgpsheading=0; 
  float cgaltitude=0; 
  float dhomeheading=0; 
  float dheadingfromhome=0; 
  float ddistmeters=0; 
  ///////////////////
  PGraphics stg; 
  PImage stgi; 
  PShape sphere; 
  PGraphics sTw; 
  PGraphics sTx; 
  PGraphics sTxL; 
  PGraphics sTxLM; 
  fscmdOrientationDisplay(int POSX, int POSY, int SIZE, float MAXDISTMETERS) {
    posx=POSX; 
    posy=POSY; 
    size=SIZE; 
    maxDistMeters=MAXDISTMETERS; 
    stg=createGraphics(stgiRes, stgiRes); 
    stg.beginDraw(); 
    stg.background(0); 
    stg.noStroke(); 
    stg.strokeWeight(2); 
    stg.stroke(255, 0, 0); 
    stg.line(0, stgiRes/2, stgiRes, stgiRes/2); 
    stg.stroke(255); 
    stg.strokeWeight(2); 
    for (int i=-90; i<90; i+=15) {
      stg.line(0, map(i, -90, 90, 0, stgiRes), stgiRes, map(i, -90, 90, 0, stgiRes));
    }
    for (int i=0; i<360; i+=15) {
      stg.line(map(i, 0, 360, 0, stgiRes), 0, map(i, 0, 360, 0, stgiRes), stgiRes);
    }
    stg.fill(255); 
    stg.textSize(stgiRes/70.00); 
    stg.pushMatrix(); 
    stg.scale(-1, 2); 
    for (int i=0; i<360; i+=15) {
      stg.text(nf(i, 3, 0), map(i, 360, 0, 0, -stgiRes), stgiRes/4);
    }
    stg.popMatrix(); 
    stg.stroke(255, 255); 
    stg.strokeWeight(4); 
    for (int i=90; i<360; i+=90) {
      stg.line(map(i, 0, 360, 0, stgiRes), 0, map(i, 0, 360, 0, stgiRes), stgiRes);
    }
    stg.strokeWeight(7);
    stg.stroke(255, 0, 0); 
    stg.line(2, 0, 2, stgiRes); 
    stg.endDraw(); 
    stgi=stg.get(); 
    sTw=createGraphics(size, size, P3D); 
    sTx=createGraphics(size, size, P3D); 
    sTxL=createGraphics(int(landRat*maxDistMeters), int(landRat*maxDistMeters)); 
    sTxLM=createGraphics(int(landRat*maxDistMeters), int(landRat*maxDistMeters)); 
    sTxLM.beginDraw(); 
    sTxLM.background(0); 
    sTxLM.noStroke(); 
    sTxLM.fill(255); 
    sTxLM.ellipse(landRat*maxDistMeters/2, landRat*maxDistMeters/2, landRat*maxDistMeters, landRat*maxDistMeters); 
    sTxLM.endDraw(); 
    sTxL.beginDraw(); 
    sTxL.background(0, 150, 0); 
    sTxL.stroke(255); 
    for (float x=-landRat*maxDistMeters/2; x<=landRat*maxDistMeters/2; x+=landRat/2.0*10) {
      sTxL.line(x+landRat*maxDistMeters/2, 0, x+landRat*maxDistMeters/2, landRat*maxDistMeters); 
      sTxL.line(0, x+landRat*maxDistMeters/2, landRat*maxDistMeters, x+landRat*maxDistMeters/2);
    } 
    sTxL.strokeWeight(3); 
    for (float x=-landRat*maxDistMeters/2; x<=landRat*maxDistMeters/2; x+=landRat/2.0*100) {
      sTxL.line(x, 0, x, landRat*maxDistMeters);
    }
    sTxL.strokeWeight(2);
    sTxL.stroke(0, 255, 255);
    sTxL.noFill();
    for (float x=0; x<=landRat*maxDistMeters; x+=landRat/2.0*250) {
      sTxL.ellipse(landRat*maxDistMeters/2, landRat*maxDistMeters/2, x, x);
    } 
    sTxL.strokeWeight(3); 
    sTxL.stroke(255, 100, 255); 
    for (int x=0; x<180; x+=15) {
      sTxL.line(-landRat*maxDistMeters*cos(radians(x))/2+landRat*maxDistMeters/2, -landRat*maxDistMeters*sin(radians(x))/2+landRat*maxDistMeters/2, landRat*maxDistMeters*cos(radians(x))/2+landRat*maxDistMeters/2, landRat*maxDistMeters*sin(radians(x))/2+landRat*maxDistMeters/2);
    }
    sTxL.endDraw(); 
    sTxL.mask(sTxLM.get()); 
    sTw.sphereDetail(55); 
    sphere=sTw.createShape(SPHERE, size*2); 
    sphere.setTexture(stgi);
  }
  void display(float Oriqw, float Oriqx, float Oriqy, float Oriqz, float GpsHeading, float CGAltitude, float DHomeHeading, float DHeadingFromHome, float DDistMeters) {
    oriqw=Oriqw; 
    oriqx=Oriqx; 
    oriqy=Oriqy; 
    oriqz=Oriqz; 
    cgaltitude=CGAltitude; 
    dgpsheading=GpsHeading; 
    dhomeheading=DHomeHeading; 
    dheadingfromhome=DHeadingFromHome; 
    ddistmeters=DDistMeters; 


    sTw.beginDraw(); 
    sTw.perspective(radians(90), 1, 1, 100000); 
    sTw.background(0); 
    sTw.pushMatrix(); 
    sTw.translate(size/2, size/2, (size/2.0) / tan(PI*30.0 / 180.0)); 
    float[] rEs=fscmdoritoAxisAngle(); 
    sTw.rotateY(radians(180)); 
    sTw.rotate(rEs[0], rEs[2], rEs[3], rEs[1]);
    sTw.shape(sphere); 
    sTw.noStroke(); 
    sTw.fill(0, 255, 0, 90); 
    sTw.translate(0, size/10, 0); 
    sTw.box(size/5); 
    sTw.fill(0, 0, 255, 90); 
    sTw.translate(0, -2*size/10, 0); 
    sTw.box(size/5); 
    sTw.popMatrix(); 
    sTw.endDraw(); 

    sTx.beginDraw(); 
    sTx.perspective(radians(90), 1, 1, 100000); 
    sTx.background(255); 
    sTx.pushMatrix(); 
    sTx.translate(size/2, size/2, (size/2.0) / tan(PI*30.0 / 180.0)); 
    sTx.rotateY(radians(180)); 
    sTx.rotate(rEs[0], rEs[2], rEs[3], rEs[1]);
    sTx.pushMatrix(); 
    sTx.translate(-cos(-radians(dheadingfromhome))*ddistmeters*landRat/2, cgaltitude*landRat, sin(-radians(dheadingfromhome))*ddistmeters*landRat/2); 
    sTx.rotateX(radians(450)); 
    sTx.image(sTxL, -landRat*maxDistMeters/2, -landRat*maxDistMeters/2); 
    sTx.fill(255, 182, 0); 
    sTx.rotate(radians(dhomeheading)); 
    sTx.strokeWeight(1); 
    sTx.stroke(0); 
    sTx.box(landRat*maxDistMeters/300); 
    sTx.translate(landRat*maxDistMeters/600, 0, landRat*maxDistMeters/1200); 
    sTx.noStroke(); 
    sTx.fill(0, 5, 255); 
    sTx.sphere(landRat*maxDistMeters/750); 
    sTx.popMatrix(); 
    sTx.translate(0, cgaltitude*landRat, 0); 
    sTx.rotateX(radians(90)); 
    sTx.strokeWeight(5); 
    sTx.stroke(50, 50, 255); 
    sTx.line(0, 0, cos(-radians(dgpsheading))*maxDistMeters*landRat*12, -sin(-radians(dgpsheading))*maxDistMeters*landRat*12); 
    sTx.stroke(0, 50, 0); 
    sTx.line(0, 0, -cos(radians(-dheadingfromhome))*maxDistMeters*landRat*12, sin(radians(-dheadingfromhome))*maxDistMeters*landRat*12); 
    sTx.pushMatrix();
    sTx.translate(0, 0, cgaltitude*landRat+size);
    sTx.stroke(0, 100, 0); 
    sTx.line(0, 0, -cos(radians(-dheadingfromhome))*maxDistMeters*landRat*12, sin(radians(-dheadingfromhome))*maxDistMeters*landRat*12); 
    sTx.popMatrix();
    sTx.noStroke(); 
    sTx.fill(255, 0, 255);
    sTx.ellipse(0, 0, maxDistMeters*landRat/300, maxDistMeters*landRat/300);
    sTx.strokeWeight(3);
    sTx.stroke(200, 70, 70);
    sTx.line(-cos(-radians(dheadingfromhome))*ddistmeters*landRat/2, sin(-radians(dheadingfromhome))*ddistmeters*landRat/2, -cos(-radians(dheadingfromhome))*ddistmeters*landRat/2+ cos(radians(dhomeheading))*maxDistMeters*landRat/2, sin(-radians(dheadingfromhome))*ddistmeters*landRat/2+sin(radians(dhomeheading))*maxDistMeters*landRat/2);
    sTx.popMatrix(); 
    sTx.endDraw(); 
    noStroke(); 
    image(sTx, posx, posy, size, size); 
    tint(255, 100); 
    image(sTw, posx, posy, size, size); 
    noTint(); 
    strokeWeight(1); 
    stroke(255, 0, 0, 150); 
    line(posx, posy+size/2, posx+size, posy+size/2); 
    line(posx+size/2, posy, posx+size/2, posy+size);
  }
  float[] fscmdoritoAxisAngle() {
    float[] res = new float[4]; 
    float sa = (float) sqrt(1.0f - oriqw * oriqw); 
    if (sa < 1.1920928955078125E-8f) {
      sa = 1.0f;
    } else {
      sa = 1.0f / sa;
    }
    res[0] = (float) acos(-oriqw) * 2.0f; 
    res[1] = -oriqx * sa; 
    res[2] = -oriqy * sa; 
    res[3] = oriqz * sa; 
    return res;
  }
}
class fscmdHeadingDistanceDisplay {
  /////////////setup vars
  int posCX; 
  int posCy; 
  int size; 
  float maxDistMeters; 

  /////////////internal vars
  float distDispPixels; 

  /////////////display vars
  float dHomeHeading; 
  float dHeadingFromHome; 
  float dDOFHeading; 
  float dGPSHeading; 
  float dDistMeters; 

  fscmdHeadingDistanceDisplay(int PosCX, int PosCy, int Size, float MaxDispMeters) {
    posCX=PosCX; 
    posCy=PosCy; 
    size=Size; 
    maxDistMeters=MaxDispMeters;
  }
  void display(float DHomeHeading, float DHeadingFromHome, float DDistMeters, float DDOFHeading, float DGPSHeading) {
    dHomeHeading=DHomeHeading; 
    dHeadingFromHome=DHeadingFromHome; 
    dDistMeters=DDistMeters; 
    dDOFHeading=DDOFHeading; 
    dGPSHeading=DGPSHeading; 
    fill(10, 50, 10); 
    stroke(255); 
    strokeWeight(1); 
    ellipse(posCX, posCy, size, size); //background

    fill(100); 
    triangle(posCX-size/25, posCy, posCX+size/25, posCy, posCX, posCy-size/10); //home station heading
    noStroke(); 
    fill(255, 0, 0); 
    ellipse(posCX, posCy, 5, 5); 
    stroke(255); 
    strokeWeight(1); 

    pushMatrix(); 
    translate(posCX, posCy); 
    rotate(PI-radians(dHomeHeading)); 
    fill(155, 0, 0); 
    triangle(-size/30, size*.4, size/30, size*.4, 0, size*.48); //north
    popMatrix(); 

    pushMatrix(); 
    translate(posCX, posCy); 
    rotate(PI-radians(dHomeHeading-dHeadingFromHome)); 
    distDispPixels=int(constrain(map(dDistMeters, 0, maxDistMeters, 0, size/2-size/10), 0, (size/2)-size/10)); //flyer
    translate(0, distDispPixels); 
    rotate(radians(dDOFHeading-dHeadingFromHome)); 
    fill(255, 205, 255); 
    triangle(-size/35, 0, size/35, 0, 0, size/12); 
    fill(255, 0, 0); 
    ellipse(0, 0, 6, 6); 
    rotate(-radians(dDOFHeading-dHeadingFromHome)); 
    rotate(radians((dGPSHeading-dHeadingFromHome))); 
    strokeWeight(2); 
    stroke(0, 0, 255); 
    line(0, 0, 0, size/11); //gps plane direction
    popMatrix();
  }
}
class Slider {
  float x;
  float y;
  float w;
  color c;
  String t;
  float val;
  float min;
  float max;
  boolean m=false;
  boolean n=false;
  String valStr="";
  Slider(float X, float Y, float W, color C, String T, float VAL, float MIN, float MAX) {
    x=X;
    y=Y;
    w=W;
    c=C;
    t=T;
    val=VAL;
    min=MIN;
    max=MAX;
  }
  float run(float V) {
    val=V;
    noStroke();
    fill(red(c)/1.5, green(c)/1.5, blue(c)/1.5);
    rect(x-5, y-2, w+10, 4);
    textSize(12);
    fill(c);
    text(t, x+w+7, y+3);
    if (!n) {
      text((nf(val, 3, 6)), x-100, y+3);
    }
    if (mouseX>=x-100&&mouseX<=x-10&&mouseY<=y+3&&mouseY>=y-10&&mousePushed) {
      n=true;
      valStr="";
    } else if (n==true&&(mousePushed||(keyPressed&&key==ENTER))) {
      n=false;
      if (float(valStr)==float(valStr)) {//NaN check!
        val=float(valStr);
      }
    }
    if (n) {
      text(valStr, x-100, y+3);
      stroke(red(c)/2, green(c)/2, blue(c)/2);
      strokeWeight(1);
      noFill();
      rect(x-103, y+4, 102, -14);
      if (((key==45||key ==46||(key>=48&&key<=57)) && (key != CODED)&&keyPushed&&textWidth(valStr)<98)) {
        valStr+=key;
      }
      if (keyPushed&&key==BACKSPACE&&valStr.length()>0) {
        valStr=valStr.substring(0, valStr.length()-1);
      }
    }
    noStroke();
    fill(255);
    if (mousePushed) {
      if ((mouseX>=x-5&&mouseX<=x+w+5&&mouseY>=y-5&&mouseY<=y+5)) {
        m=true;
      } else {
        m=false;
      }
    }
    if (!mousePressed) {
      m=false;
    }
    if (m) {
      val=constrain(map(mouseX-x, 0, w, min, max), min, max);
      fill(100);
    }
    rect(x+-5+constrain(map(val, min, max, 0, w), 0, w), y-5, 10, 10);
    return val;
  }
}
void mousePressed() {
  mousePushed=true;
}
void keyPressed() {
  keyPushed=true;
}
