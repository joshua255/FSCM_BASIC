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
import java.util.List;
import processing.net.*;
import java.util.Date;
/////////////////////////////reusable functions for fscm************************************************************
Table telog;
boolean telogging=false;
boolean fscmDJustGotTS=false;
boolean wastelogging=false;
Table points;
int pointHovered=-1;
int pointClicked=-1;
boolean clickpoint=false;
boolean hoverpoint=false;
float[] fscmFEul=new float[3];
int fscmdTSi=0;
boolean homeSet=false;
String[] fscmdTSInfo;
String fscmdTSIn;
boolean mousePushed=false;
boolean keyPushed=false;
boolean mouseDragged=false;
long fscmDMillisGotTS=0;
long fscmDTConnTime=0;
import processing.serial.*;
Serial fscmTS;
void setupPoints() {
  points = new Table();
  points.addColumn("ID", Table.INT);
  points.addColumn("Latitude", Table.FLOAT);
  points.addColumn("Longitude", Table.FLOAT);
  points.addColumn("Altitude", Table.FLOAT);
}
void fscmDLoadWaypoints() {
  try {
    if (loadTable("/waypoints/points.csv", "header")!=null) {
      points=loadTable("/waypoints/points.csv", "header");
    }
  }
  catch(Exception e) {
    println("error loading waypoints");
  }
}
void fscmDSaveWaypoints() {
  saveTable(points, "/waypoints/points.csv");
}
void fscmDWaypointsSend() {
  if (sendWPoints==false&&fscmDJustGotTS) {
    pointsWI=0;
    SWPB.msg="send points";
  }
  if (sendWPoints) {
    if (fscmDJustGotTS) {
      println("sending");
      if (byte(points.getRowCount())<=25) {//size of fscmF waypoints array
        pointsWNum=byte(points.getRowCount());
        if (pointsWI<100) {
          pointsWI=100;
        }
        if (pointsWI>=100+points.getRowCount()) {
          sendWPoints=false;
          pointsWI=0;
        } else {
          SWPB.msg=str(pointsWI-99)+"/"+nf(pointsWNum);
          if (pointsWI>=100&&pointsWI<100+points.getRowCount()) {          
            pointsWI++;
            pointsWLat=points.getFloat(pointsWI-101, "Latitude");
            pointsWLon=points.getFloat(pointsWI-101, "Longitude");
            pointsWAlt=points.getFloat(pointsWI-101, "Altitude");
          }
        }
      } else {
        SWPB.msg="overflow";
        sendWPoints=false;
      }
    }
  }
  if (SWPB.display(sendWPoints)) {
    sendWPoints=true;
  }
}
void runTelog() {
  if (telogging&&!wastelogging) {
    setupTelog();
  }
  if (!telogging&&wastelogging) {
    saveTelog();
  }
  if (telogging) {
    recTelog();
  }
}
void setupTelog() {
  telog = new Table();
  telog.addColumn("fscmD millis", Table.LONG);
  telog.addColumn("fscmHomeSet", Table.INT);
  telog.addColumn("setHome", Table.INT);
  telog.addColumn("fscmHomeLat", Table.FLOAT);
  telog.addColumn("fscmHomeLon", Table.FLOAT);
  telog.addColumn("fscmHomeHeading", Table.FLOAT);
  telog.addColumn("heading fm home", Table.FLOAT);
  telog.addColumn("fscmFSigStrengthOfTran", Table.INT);
  telog.addColumn("fscmTSigStrengthFromF", Table.INT);
  telog.addColumn("fscmFOriSystemCal", Table.INT);
  telog.addColumn("fscmFOriGyroCal", Table.INT);
  telog.addColumn("fscmFOriAccelCal", Table.INT);
  telog.addColumn("fscmFOriMagCal", Table.INT);
  telog.addColumn("fscmFGpsLat", Table.FLOAT);
  telog.addColumn("fscmFGpsLon", Table.FLOAT);
  telog.addColumn("fscmFGpsSatStat", Table.FLOAT);
  telog.addColumn("fscmFGpsSpeed", Table.FLOAT);
  telog.addColumn("fscmFGpsHeading", Table.FLOAT);
  telog.addColumn("fscmFDistMeters", Table.INT);
  telog.addColumn("fscmFHeadFmHome", Table.FLOAT);
  telog.addColumn("fscmFOriQuatX", Table.FLOAT);
  telog.addColumn("fscmFOriQuatY", Table.FLOAT);
  telog.addColumn("fscmFOriQuatZ", Table.FLOAT);
  telog.addColumn("fscmFOriQuatW", Table.FLOAT);
  telog.addColumn("fscmFGAlt", Table.FLOAT);
  telog.addColumn("fscmFBatVolt", Table.FLOAT);
  telog.addColumn("fscmFSigStrengthOfTran", Table.INT);
  telog.addColumn("fscmTSigStrengthFromF", Table.INT);
  telog.addColumn("fscmTBatVVal", Table.FLOAT);
  telog.addColumn("fscmTRJXBVal", Table.INT);
  telog.addColumn("fscmTRJYBVal", Table.INT);
  telog.addColumn("fscmTLJXBVal", Table.INT);
  telog.addColumn("fscmTLJYBVal", Table.INT);
  telog.addColumn("fscmTLKBVal", Table.INT);
  telog.addColumn("fscmTRKBVal", Table.INT);
  telog.addColumn("fscmTLTVal", Table.INT);
  telog.addColumn("fscmTRTVal", Table.INT);
  telog.addColumn("fscmTLBVal", Table.INT);
  telog.addColumn("fscmTRBVal", Table.INT);
  telog.addColumn("fscmTETVal", Table.INT);
  telog.addColumn("fscmFConnTime", Table.INT);
  telog.addColumn("fscmCPitch", Table.FLOAT);
  telog.addColumn("fscmCRoll", Table.FLOAT);
  telog.addColumn("fscmFConnTime", Table.INT);
  telog.addColumn("fscmTConnTime", Table.INT);
}
void recTelog() {
  TableRow telrow=telog.addRow();
  telrow.setLong("fscmD millis", millis());
  telrow.setInt("fscmHomeSet", int(fscmHomeSet));
  telrow.setInt("setHome", int(setHome));
  telrow.setFloat("fscmHomeLat", fscmHomeLat);
  telrow.setFloat("fscmHomeLon", fscmHomeLon);
  telrow.setFloat("fscmHomeHeading", fscmHomeHeading);
  telrow.setFloat("fscmFHeadFmHome", fscmFHeadFmHome);
  telrow.setInt("fscmFSigStrengthOfTran", fscmFSigStrengthOfTran);
  telrow.setInt("fscmTSigStrengthFromF", fscmTSigStrengthFromF);
  telrow.setInt("fscmFOriSystemCal", fscmFOriSystemCal);
  telrow.setInt("fscmFOriGyroCal", fscmFOriGyroCal);
  telrow.setInt("fscmFOriAccelCal", fscmFOriAccelCal);
  telrow.setInt("fscmFOriMagCal", fscmFOriMagCal);
  telrow.setFloat("fscmFGpsLat", fscmFGpsLat);
  telrow.setFloat("fscmFGpsLon", fscmFGpsLon);
  telrow.setFloat("fscmFGpsSatStat", fscmFGpsSatStat);
  telrow.setFloat("fscmFGpsSpeed", fscmFGpsSpeed);
  telrow.setFloat("fscmFGpsHeading", fscmFGpsHeading);
  telrow.setInt("fscmFDistMeters", fscmFDistMeters);
  telrow.setFloat("fscmFHeadFmHome", fscmFHeadFmHome);
  telrow.setFloat("fscmFOriQuatX", fscmFOriQuatX);
  telrow.setFloat("fscmFOriQuatY", fscmFOriQuatY);
  telrow.setFloat("fscmFOriQuatZ", fscmFOriQuatZ);
  telrow.setFloat("fscmFOriQuatW", fscmFOriQuatW);
  telrow.setFloat("fscmFGAlt", fscmFGAlt);
  telrow.setFloat("fscmFBatVolt", fscmFBatVolt);
  telrow.setInt("fscmFSigStrengthOfTran", fscmFSigStrengthOfTran);
  telrow.setInt("fscmTSigStrengthFromF", fscmTSigStrengthFromF);
  telrow.setFloat("fscmTBatVVal", fscmTBatVVal);
  telrow.setInt("fscmTRJXBVal", fscmTRJXBVal);
  telrow.setInt("fscmTRJYBVal", fscmTRJYBVal);
  telrow.setInt("fscmTLJXBVal", fscmTLJXBVal);
  telrow.setInt("fscmTLJYBVal", fscmTLJYBVal);
  telrow.setInt("fscmTLKBVal", fscmTLKBVal);
  telrow.setInt("fscmTRKBVal", fscmTRKBVal);
  telrow.setInt("fscmTLTVal", int(fscmTLTVal));
  telrow.setInt("fscmTRTVal", int(fscmTRTVal));
  telrow.setInt("fscmTLBVal", int(fscmTLBVal));
  telrow.setInt("fscmTRBVal", int(fscmTRBVal));
  telrow.setInt("fscmTETVal", int(fscmTETVal));
  telrow.setInt("fscmFConnTime", fscmFConnTime);
  telrow.setFloat("fscmCPitch", fscmCPitch);
  telrow.setFloat("fscmCRoll", fscmCRoll);
  telrow.setInt("fscmFConnTime", fscmFConnTime);
  telrow.setInt("fscmTConnTime", int(fscmDTConnTime));
}
void saveTelog() {
  saveTable(telog, "telog/FSCMlog"+(new Date()).getTime()+".csv");
  telog.clearRows();
}
class fscmdMapStatus {
  int x;
  int y;
  int w;
  int h;
  int sel=-1;
  int vid=-1;
  String str="";
  fscmdMapStatus(int X, int Y, int W, int H) {
    x=X;
    y=Y;
    w=W;
    h=H;
  }
  void display(Table Points) {
    strokeWeight(0);
    fill(30);
    rect(x, y, w, h);
    if (pointClicked>=0&&pointClicked<=255) {
      fill(255);
      textSize(10);
      points.setFloat(pointClicked, "Latitude", textBox(1, pointClicked, points.getFloat(pointClicked, "Latitude"), 3, y+10, w-6));
      text("Latitude", 3, y+10);
      points.setFloat(pointClicked, "Longitude", textBox(2, pointClicked, points.getFloat(pointClicked, "Longitude"), 3, y+30, w-6));
      text("Longitude", 3, y+30);
      points.setFloat(pointClicked, "Altitude", textBox(0, pointClicked, points.getFloat(pointClicked, "Altitude"), 3, y+50, w-6));
      text("Altitude", 3, y+50);
      fill(150, 0, 0);
      stroke(255);
      rect(x+5, y+h-3, w-10, -15);
      fill(255);
      text("right click here to delete point", x+5, y+h-10);
      if (mouseX>x+5&&mouseY>y+h-3-15&&mouseX<x+w-10&&mouseY<y+h-3&&mousePushed&&mouseButton==RIGHT) {
        mousePushed=false;
        points.removeRow(pointClicked);
        for (int j=pointClicked; j<points.getRowCount(); j++) {
          points.setInt(j, "ID", j);
        }
        pointHovered=-1;
        pointClicked=-1;
      }
    }
  }
  float textBox(int VID, int pc, float val, int x, int y, int w) {
    textSize(10);
    if (mousePushed&&mouseX>=x&&mouseX<=x+w&&mouseY>=y&&mouseY<=y+10) {
      sel=pc;
      str="";
      vid=VID;
    }
    if (keyPushed&&key==ENTER) {
      sel=-1;
    }
    if (sel==pc&&vid==VID) {
      stroke(255);
      if (((key==45||key ==46||(key>=48&&key<=57)) && (key != CODED)&&keyPushed&&textWidth(str)<w)) {
        str+=key;
      }
      if (keyPushed&&key==BACKSPACE&&str.length()>0) {
        str=str.substring(0, str.length()-1);
      }
    } else if (vid==VID) {
      stroke(30);
      if (str!=""&&float(str)==float(str)) {
        val=float(str);
      }
      vid=-1;
      str="";
    }
    fill(15);
    rect(x, y, w, 10);      
    if (sel==pc&&vid==VID) {
      fill(125);
      text(str, x, y+10);
    } else {
      fill(255);
      text(val, x-4, y+10);
    }
    return val;
  }
}
class fscmdMapDisplay {
  int x;
  int y;
  int s;
  float maxDispFlyDistMeters;
  UnfoldingMap map;
  PGraphics mpg;
  EventDispatcher eventDispatcher;
  fscmdMapDisplay(int X, int Y, int S, float MaxDispFlyDistMeters) {
    x=X;
    y=Y;
    s=S;
    maxDispFlyDistMeters=MaxDispFlyDistMeters;
    map = new UnfoldingMap(fscmD.this, x, y, s, s, new Microsoft.HybridProvider());
    map.setZoomRange(4, 18);
    map.zoomAndPanTo(10, new Location(fscmHomeLat, fscmHomeLon));
    eventDispatcher = new EventDispatcher();
    MouseHandler mouseHandler = new MouseHandler(fscmD.this, map);
    eventDispatcher.addBroadcaster(mouseHandler);
    eventDispatcher.register(map, PanMapEvent.TYPE_PAN, map.getId());
    eventDispatcher.register(map, ZoomMapEvent.TYPE_ZOOM, map.getId());
    mpg=createGraphics(s, s, P2D);
  }
  void display(float FscmFGpsLat, float FscmFGpsLon, float DHomeHeading, float DDOFHeading, float DGPSHeading, float FscmHomeLat, float FscmHomeLon) {
    if (homeSet) {
      List<Location> zoomloclist = new ArrayList<Location>();
      map.rotateTo(0);
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(FscmHomeLat, FscmHomeLon), 90, maxDispFlyDistMeters/1110.00)));
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(FscmHomeLat, FscmHomeLon), 180, maxDispFlyDistMeters/1110.00)));
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(FscmHomeLat, FscmHomeLon), 270, maxDispFlyDistMeters/1110.00)));
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(FscmHomeLat, FscmHomeLon), 0, maxDispFlyDistMeters/1110.00)));
      map.zoomAndPanToFit(zoomloclist);
      map.rotateTo(-radians(DHomeHeading));
      while (!map.allTilesLoaded()) {
        map.draw();
      }
    }
    if (pointClicked>=0&&pointClicked<=255) {
      eventDispatcher.unregister(map, PanMapEvent.TYPE_PAN, map.getId());
      eventDispatcher.unregister(map, ZoomMapEvent.TYPE_ZOOM, map.getId());
    } else {
      eventDispatcher.register(map, PanMapEvent.TYPE_PAN, map.getId());
      eventDispatcher.register(map, ZoomMapEvent.TYPE_ZOOM, map.getId());
    }
    map.draw();
    strokeWeight(1);
    stroke(255);
    pushMatrix(); 
    translate(x+s/2, y+s/2); 
    rotate(PI-radians(DHomeHeading)); 
    fill(155, 0, 0); 
    triangle(-s*.008, s*.45, s*.008, s*.45, 0, s*.49); //north
    popMatrix();
    if (mousePushed&&mouseButton==RIGHT&&mouseX>x&&mouseX<x+s&&mouseY>y&&mouseY<y+s) {
      Location ploc= map.getLocationFromScreenPosition(mouseX, mouseY);
      points.addRow();
      points.setInt(points.getRowCount()-1, "ID", points.getRowCount()-1);
      points.setFloat(points.getRowCount()-1, "Latitude", ploc.getLat());
      points.setFloat(points.getRowCount()-1, "Longitude", ploc.getLon());
    }
    if (mousePressed&&mouseDragged&&!mousePushed&&mouseX>x&&mouseX<x+s&&mouseY>y&&mouseY<y+s&&pointClicked==pointHovered&&pointClicked>=0&&pointClicked<=255) {
      Location ploc= map.getLocationFromScreenPosition(mouseX, mouseY);
      points.setInt(pointClicked, "ID", pointClicked);
      points.setFloat(pointClicked, "Latitude", ploc.getLat());
      points.setFloat(pointClicked, "Longitude", ploc.getLon());
    }
    mpg.beginDraw();
    mpg.clear();
    for (int i=0; i<points.getRowCount(); i++) {
      marker(i, map.getScreenPosition(new Location(points.getFloat(i, "Latitude"), points.getFloat(i, "Longitude"))).x-x, map.getScreenPosition(new Location(points.getFloat(i, "Latitude"), points.getFloat(i, "Longitude"))).y-y, colorHSB(map(i, 0, points.getRowCount(), 0, 255), 100, 255), nf(points.getInt(i, "ID")), nf(points.getFloat(i, "Altitude"), 0, 1), nf((540-DDOFHeading+degrees((float)GeoUtils.getAngleBetween(new Location(FscmFGpsLat, FscmFGpsLon), new Location(points.getFloat(i, "Latitude"), points.getFloat(i, "Longitude")))))%360-180, 0, 2), str((int)(1000.0000*GeoUtils.getDistance(FscmFGpsLat, FscmFGpsLon, points.getFloat(i, "Latitude"), points.getFloat(i, "Longitude")))));
    }
    if (clickpoint==false&&mousePushed&&mouseX>x&&mouseX<x+s&&mouseY>y&&mouseY<y+s) {
      pointClicked=-1;
    }
    clickpoint=false;
    if (hoverpoint==false) {
      pointHovered=-1;
    }
    hoverpoint=false;
    marker(256, map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).x-x, map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).y-y, color(255), "home", "0", nf((720-DDOFHeading+fscmFHeadFmHome)%360-180, 0, 3), nf(fscmFDistMeters));
    circleLocRDm(new Location(FscmHomeLat, FscmHomeLon), maxDispFlyDistMeters/4, color(0, 200, 0));
    circleLocRDm(new Location(FscmHomeLat, FscmHomeLon), maxDispFlyDistMeters/2, color(200, 200, 0));
    circleLocRDm(new Location(FscmHomeLat, FscmHomeLon), maxDispFlyDistMeters, color(200, 0, 0));
    mpg.pushMatrix(); 
    mpg.translate(map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).x-x, map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).y-y);
    mpg.pushMatrix();
    mpg.rotate(3*PI/2-radians(DHomeHeading)); 
    if (fscmFWPI>0) {
      mpg.stroke(255, 90, 255);
      mpg.strokeWeight(2);
      mpg.line(0, 0, cos(radians(fscmFWH))*getDistance(new Location(FscmFGpsLat, FscmFGpsLon), fscmFWD), sin(radians(fscmFWH))*getDistance(new Location(FscmFGpsLat, FscmFGpsLon), fscmFWD));
    }
    mpg.popMatrix();
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
    mpg.rotate(PI+radians((DGPSHeading-DHomeHeading)));
    mpg.stroke(0, 0, 255, 180); 
    mpg.strokeWeight(6);
    ScreenPosition pos=map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon));
    float r=getDistance(new Location(FscmFGpsLat, FscmFGpsLon), fscmFGpsSpeed*30);
    mpg.line(0, 0, 0, r); //gps plane direction
    mpg.strokeWeight(2);
    mpg.line(0, 0, 0, s); //gps plane direction
    mpg.popMatrix();
    mpg.strokeWeight(1);
    mpg.stroke(255, 200);
    mpg.line(map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).x-x, map.getScreenPosition(new Location(FscmFGpsLat, FscmFGpsLon)).y-y, map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).x-x, map.getScreenPosition(new Location(FscmHomeLat, FscmHomeLon)).y-y);
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
    mpg.fill(C);
    mpg.textSize(9);
    mpg.textAlign(CENTER);
    mpg.text(int(R), pos.x-x, pos.y-y-r+15);
    mpg.textAlign(RIGHT);
    mpg.textSize(10);
  }
  float getDistance(Location mainLocation, float mLength) {
    Location tempLocation = GeoUtils.getDestinationLocation(mainLocation, 90, mLength/1000.00);
    ScreenPosition pos1 = map.getScreenPosition(mainLocation);
    ScreenPosition pos2 = map.getScreenPosition(tempLocation);
    return dist(pos1.x, pos1.y, pos2.x, pos2.y);
  }
  void marker(int i, float X, float Y, color C, String Name, String Alt, String Heading, String Distance) {
    mpg.strokeWeight(1);
    mpg.stroke(C);
    mpg.fill(C, 120);
    mpg.line(X+10, Y, X-10, Y);
    mpg.line(X, Y+10, X, Y-10);
    mpg.textSize(10);
    if (sq(mouseX-(x+X))+sq(mouseY-(y+Y))<=sq(10)&&!hoverpoint) {
      pointHovered=i;
      hoverpoint=true;      
      if (mousePressed&&mouseButton==LEFT) {
        clickpoint=true;
      }
      if (mousePushed&&mouseButton==LEFT) {
        pointClicked=i;
      }
    }
    mpg.textAlign(CENTER);
    if (pointHovered==i) {
      if (pointClicked!=i) {
        mpg.fill(150, 170);
        mpg.rect(X-6-max(mpg.textWidth(Name), mpg.textWidth(Heading)), Y-20, max(mpg.textWidth(Name), mpg.textWidth(Heading))+17+max(mpg.textWidth(Alt), mpg.textWidth(Distance)), 35);
      }
      mpg.fill(255);
    }
    if (pointClicked==i) {
      mpg.fill(150, 220);
      mpg.rect(X-6-max(mpg.textWidth(Name), mpg.textWidth(Heading)), Y-20, max(mpg.textWidth(Name), mpg.textWidth(Heading))+17+max(mpg.textWidth(Alt), mpg.textWidth(Distance)), 35);
      mpg.fill(200);
    }
    mpg.ellipse(X, Y, 10, 10);
    mpg.fill(C);
    mpg.text(Alt, X+9+mpg.textWidth(Alt)/2, Y-9);
    mpg.text(Distance, X+9+mpg.textWidth(Distance)/2, Y+11);
    mpg.text(Name, X-6-mpg.textWidth(Name)/2, Y-9);
    mpg.text(Heading, X-6-mpg.textWidth(Heading)/2, Y+11);
  }
}
color colorHSB(float H, float S, float B) {
  pushStyle();
  colorMode(HSB);
  color ret=color(H, S, B);
  popStyle();
  return ret;
}
class fscmdButton {
  int x;
  int y;
  int w;
  int h;
  color c;
  boolean l;
  String msg;
  boolean t=false;
  boolean lp=false;
  boolean jp=false;
  fscmdButton(int X, int Y, int W, int H, color C, boolean L, String MSG) {
    x=X;
    y=Y;
    w=W;
    h=H;
    c=C;
    l=L;
    msg=MSG;
  }
  boolean display(boolean v) {
    t=v;
    pushStyle();
    strokeWeight(4);
    stroke(c);
    textLeading(15);
    jp=false;
    if (mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h&&mousePressed) {
      stroke(red(c)/2, green(c)/2, blue(c));
      if (lp==false) {
        if (l) {
          t=!t;
          jp=true;
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
    rect(x, y, w, h);
    textSize(14);
    fill(155);
    text(msg, x, y, w, h);
    popStyle();
    return t;
  }
}
void serialEvent(Serial fscmTS) {
  fscmDTConnTime=millis()-fscmDMillisGotTS;
  fscmDMillisGotTS=millis();
  fscmDJustGotTS=true;
  fscmdTSIn=fscmTS.readString();
  fscmdTSInfo=split(fscmdTSIn, ',');
  fscmdTSIn="";
  fscmdTSi=0;
  fscmdDataToParseFromFscmT();
  fscmTS.write("<");
  fscmdDataToSendToFscmT();
  fscmTS.write(">");
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
void fscmdSendDataFscmTBy(byte d) {
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
    fscmTS.bufferUntil('>');
  }
  catch(Exception e) {
    println("no transmitter, stopping program!");
    while (true);
  }
  delay(500);
}
void fscmdHomeSet() {
  if (fscmHomeSet==true) {
    fscmHomeHeading=fscmFEul[0];
    fscmHomeLat=fscmFGpsLat;
    fscmHomeLon=fscmFGpsLon;
    setHome=false;
    homeSet=true;
  }
}
int fscmdParseFscmTIn() {
  fscmdTSi++;
  return int(fscmdTSInfo[fscmdTSi]);
}
byte fscmdParseFscmTBy() {
  fscmdTSi++;
  return byte(int(fscmdTSInfo[fscmdTSi]));
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
  eul[0]+=MAGNETIC_VARIATION;
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
  float landRat=3; 

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
  PGraphics stg; //sphere texture
  PImage stgi; //spehre texture
  PShape sphere; 
  PGraphics sTw; 
  PGraphics sTx; 
  PGraphics sTxL; //ground
  PGraphics sTxLM; //circle mask on ground
  boolean mapped=false;
  UnfoldingMap map;
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
    sTxL=createGraphics(int(landRat*maxDistMeters*2), int(landRat*maxDistMeters*2)); 
    sTxLM=createGraphics(int(landRat*maxDistMeters*2), int(landRat*maxDistMeters*2)); 
    sTxLM.beginDraw(); 
    sTxLM.background(0); 
    sTxLM.noStroke(); 
    sTxLM.fill(255); 
    sTxLM.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters*2, landRat*maxDistMeters*2); 
    sTxLM.endDraw();
    map = new UnfoldingMap(fscmD.this, width+10, 0, landRat*maxDistMeters*2, landRat*maxDistMeters*2, new Microsoft.HybridProvider());
    sTxL.beginDraw();
    sTxL.background(0, 150, 0);
    sTxL.stroke(150);
    sTxL.strokeWeight(1);
    for (int i=0; i<int(2*landRat*maxDistMeters); i+=landRat*10) {
      sTxL.line(i, 0, i, landRat*maxDistMeters*2);
      sTxL.line(0, i, landRat*maxDistMeters*2, i);
    }
    sTxL.strokeWeight(5);
    sTxL.noFill();
    sTxL.stroke(0, 255, 0);
    sTxL.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters/4, landRat*maxDistMeters/4);
    sTxL.stroke(255, 255, 0);
    sTxL.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters/2, landRat*maxDistMeters/2);
    sTxL.stroke(255, 0, 0);
    sTxL.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters);
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
    if (homeSet) {
      List<Location> zoomloclist = new ArrayList<Location>();
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(fscmHomeLat, fscmHomeLon), 90, maxDispFlyDistMeters/1110.00)));
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(fscmHomeLat, fscmHomeLon), 180, maxDispFlyDistMeters/1110.00)));
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(fscmHomeLat, fscmHomeLon), 270, maxDispFlyDistMeters/1110.00)));
      zoomloclist.add(new Location(GeoUtils.getDestinationLocation(new Location(fscmHomeLat, fscmHomeLon), 0, maxDispFlyDistMeters/1110.00)));
      map.zoomAndPanToFit(zoomloclist);
      mapped=true;
      map.draw();
    }
    if (!map.allTilesLoaded()&&mapped) {
      map.draw();
    }
    if (map.allTilesLoaded()&&mapped) {
      mapped=false;
      sTxL.beginDraw();
      sTxL.image(map.mapDisplay.getOuterPG().get(), 0, 0, landRat*maxDistMeters*2, landRat*maxDistMeters*2);
      sTxL.stroke(150);
      sTxL.strokeWeight(1);
      for (int i=0; i<int(2*landRat*maxDistMeters); i+=landRat*10) {
        sTxL.line(i, 0, i, landRat*maxDistMeters*2);
        sTxL.line(0, i, landRat*maxDistMeters*2, i);
      }
      sTxL.strokeWeight(5);
      sTxL.noFill();
      sTxL.stroke(0, 255, 0);
      sTxL.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters/4, landRat*maxDistMeters/4);
      sTxL.stroke(255, 255, 0);
      sTxL.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters/2, landRat*maxDistMeters/2);
      sTxL.stroke(255, 0, 0);
      sTxL.ellipse(landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters, landRat*maxDistMeters);
      sTxL.endDraw(); 
      sTxL.mask(sTxLM.get());
    }
    sTw.beginDraw(); 
    sTw.perspective(radians(90), 1, 1, 100000); 
    sTw.background(0); 
    sTw.pushMatrix(); 
    sTw.translate(size/2, size/2, (size/2.0) / tan(PI*30.0 / 180.0)); 
    float[] rEs=fscmdoritoAxisAngle(); 
    sTw.rotateY(radians(180));    
    sTw.rotateY(radians(MAGNETIC_VARIATION));
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
    sTx.rotateY(radians(MAGNETIC_VARIATION));
    sTx.pushMatrix(); 
    sTx.translate(-cos(-radians(dheadingfromhome))*ddistmeters*landRat, cgaltitude*landRat, sin(-radians(dheadingfromhome))*ddistmeters*landRat);
    sTx.rotateX(radians(450));
    sTx.rotateZ(PI/2);
    sTx.image(sTxL, -landRat*maxDistMeters, -landRat*maxDistMeters); 
    sTx.rotateZ(-PI/2);
    sTx.fill(255, 182, 0, constrain(map(ddistmeters, 0, 15, 30, 255), 30, 255)); 
    sTx.rotate(radians(dhomeheading)); 
    sTx.strokeWeight(1); 
    sTx.stroke(0);
    sTx.box(landRat*maxDistMeters/500); 
    sTx.translate(landRat*maxDistMeters/600, 0, landRat*maxDistMeters/1200);
    sTx.noStroke(); 
    sTx.fill(0, 5, 255, constrain(map(ddistmeters, 0, 15, 30, 255), 30, 255)); 
    sTx.sphere(landRat*maxDistMeters/750); 
    sTx.popMatrix(); 
    sTx.translate(0, cgaltitude*landRat, 0);
    sTx.rotateX(radians(90)); 
    sTx.strokeWeight(8); 
    sTx.stroke(50, 50, 255); 
    sTx.line(0, 0, cos(-radians(dgpsheading))*fscmFGpsSpeed*landRat*30, -sin(-radians(dgpsheading))*landRat*fscmFGpsSpeed*30); 
    sTx.strokeWeight(2);
    sTx.line(0, 0, cos(-radians(dgpsheading))*maxDistMeters*landRat*30, -sin(-radians(dgpsheading))*maxDistMeters*landRat*30); 
    sTx.stroke(0, 50, 0); 
    sTx.line(0, 0, -cos(radians(-dheadingfromhome))*maxDistMeters*landRat*12, sin(radians(-dheadingfromhome))*maxDistMeters*landRat*12);
    sTx.pushMatrix();
    sTx.translate(-cos(-radians(dheadingfromhome))*ddistmeters*landRat, sin(-radians(dheadingfromhome))*ddistmeters*landRat, 0);
    sTx.rotateZ(PI/2);
    for (int i=0; i<points.getRowCount(); i++) {
      sTx.pushMatrix();
      sTx.translate((map.getScreenPosition(new Location(points.getFloat(i, "Latitude"), points.getFloat(i, "Longitude"))).x-width-10-landRat*maxDistMeters), (map.getScreenPosition(new Location(points.getFloat(i, "Latitude"), points.getFloat(i, "Longitude"))).y-landRat*maxDistMeters), landRat*points.getFloat(i, "Altitude"));
      sTx.noStroke();
      sTx.colorMode(HSB);
      sTx.fill(map(i, 0, points.getRowCount(), 0, 255), 255, 100, 128);
      sTx.sphere(WAYPOINT_CLOSE_ENOUGH_DIST*landRat);
      sTx.colorMode(RGB);
      sTx.popMatrix();
    }
    sTx.popMatrix();
    sTx.pushMatrix();
    sTx.translate(0, 0, cgaltitude*landRat+size);
    sTx.stroke(0, 100, 0); 
    sTx.line(0, 0, -cos(radians(-dheadingfromhome))*maxDistMeters*landRat*12, sin(radians(-dheadingfromhome))*maxDistMeters*landRat*12); 
    sTx.popMatrix();
    sTx.noStroke(); 
    sTx.fill(255, 0, 255);
    sTx.ellipse(0, 0, maxDistMeters*landRat/1000, maxDistMeters*landRat/1000);
    sTx.strokeWeight(3);
    sTx.stroke(200, 70, 70);
    sTx.line(-cos(-radians(dheadingfromhome))*ddistmeters*landRat, sin(-radians(dheadingfromhome))*ddistmeters*landRat, -cos(-radians(dheadingfromhome))*ddistmeters*landRat+ cos(radians(dhomeheading))*maxDistMeters*landRat, sin(-radians(dheadingfromhome))*ddistmeters*landRat+sin(radians(dhomeheading))*maxDistMeters*landRat);
    sTx.popMatrix(); 
    sTx.endDraw(); 
    noStroke(); 
    image(sTx, posx, posy, size, size); 
    tint(255, 50); 
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
//class fscmdHeadingDistanceDisplay {
//  /////////////setup vars
//  int posCX; 
//  int posCy; 
//  int size; 
//  float maxDistMeters; 

//  /////////////internal vars
//  float distDispPixels; 

//  /////////////display vars
//  float dHomeHeading; 
//  float dHeadingFromHome; 
//  float dDOFHeading; 
//  float dGPSHeading; 
//  float dDistMeters; 

//  fscmdHeadingDistanceDisplay(int PosCX, int PosCy, int Size, float MaxDispMeters) {
//    posCX=PosCX; 
//    posCy=PosCy; 
//    size=Size; 
//    maxDistMeters=MaxDispMeters;
//  }
//  void display(float DHomeHeading, float DHeadingFromHome, float DDistMeters, float DDOFHeading, float DGPSHeading) {
//    dHomeHeading=DHomeHeading; 
//    dHeadingFromHome=DHeadingFromHome; 
//    dDistMeters=DDistMeters; 
//    dDOFHeading=DDOFHeading; 
//    dGPSHeading=DGPSHeading; 
//    fill(10, 50, 10); 
//    stroke(255); 
//    strokeWeight(1); 
//    ellipse(posCX, posCy, size, size); //background

//    fill(100); 
//    triangle(posCX-size/25, posCy, posCX+size/25, posCy, posCX, posCy-size/10); //home station heading
//    noStroke(); 
//    fill(255, 0, 0); 
//    ellipse(posCX, posCy, 5, 5); 
//    stroke(255); 
//    strokeWeight(1); 

//    pushMatrix(); 
//    translate(posCX, posCy); 
//    rotate(PI-radians(dHomeHeading)); 
//    fill(155, 0, 0); 
//    triangle(-size/30, size*.4, size/30, size*.4, 0, size*.48); //north
//    popMatrix(); 

//    pushMatrix(); 
//    translate(posCX, posCy); 
//    rotate(PI-radians(dHomeHeading-dHeadingFromHome)); 
//    distDispPixels=int(constrain(map(dDistMeters, 0, maxDistMeters, 0, size/2-size/10), 0, (size/2)-size/10)); //flyer
//    translate(0, distDispPixels); 
//    rotate(radians(dDOFHeading-dHeadingFromHome)); 
//    fill(255, 205, 255); 
//    triangle(-size/35, 0, size/35, 0, 0, size/12); 
//    fill(255, 0, 0); 
//    ellipse(0, 0, 6, 6); 
//    rotate(-radians(dDOFHeading-dHeadingFromHome)); 
//    rotate(radians((dGPSHeading-dHeadingFromHome))); 
//    strokeWeight(2); 
//    stroke(0, 0, 255); 
//    line(0, 0, 0, size/11); //gps plane direction
//    popMatrix();
//  }
//}
class fscmdSlider {
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
  fscmdSlider(float X, float Y, float W, color C, String T, float VAL, float MIN, float MAX) {
    x=X;
    y=Y;
    w=W;
    c=C;
    t=T;
    val=VAL;
    min=MIN;
    max=MAX;
  }
  float display(float V) {
    val=V;
    noStroke();
    fill(red(c)/1.5, green(c)/1.5, blue(c)/1.5);
    rect(x-5, y-2, w+10, 4);
    textSize(13);
    fill(c);
    text(t, x+w+7, y+3);
    if (!n) {
      text((nf(val, 2, 4)), x-70, y+3);
    }
    if (mouseX>=x-73&&mouseX<=x-10&&mouseY<=y+1&&mouseY>=y-6&&mousePushed) {
      n=true;
      valStr="";
    } else if (n==true&&(mousePushed||(keyPressed&&key==ENTER))) {
      n=false;
      if (float(valStr)==float(valStr)) {//NaN check!
        val=float(valStr);
      }
    }
    if (n) {
      text(valStr, x-70, y+3);
      stroke(red(c)/2, green(c)/2, blue(c)/2);
      strokeWeight(1);
      noFill();
      rect(x-70, y+4, 65, -12);
      if (((key==45||key ==46||(key>=48&&key<=57)) && (key != CODED)&&keyPushed&&textWidth(valStr)<60)) {
        valStr+=key;
      }
      if (keyPushed&&key==BACKSPACE&&valStr.length()>0) {
        valStr=valStr.substring(0, valStr.length()-1);
      }
    }
    noStroke();
    fill(255);
    if (mousePushed) {
      if ((mouseX>=x-5&&mouseX<=x+w+5&&mouseY>=y-4&&mouseY<=y+4)) {
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
    rect(x-5+constrain(map(val, min, max, 0, w), 0, w), y-5, 10, 10);
    return val;
  }
}
void mousePressed() {
  mousePushed=true;
}
void keyPressed() {
  keyPushed=true;
}
void mouseDragged() {
  mouseDragged=true;
}
