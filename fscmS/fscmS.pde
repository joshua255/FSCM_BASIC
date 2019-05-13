import guru.ttslib.*; //<>//
TTS tts;
import processing.net.*;
Server s;
Client c;
String inputS="";
String[] inputs;
String input="";
boolean done=false;
void setup() {
  textSize(20);
  size(200, 150);
  background(0);
  input="fscm speaker";
  tts = new TTS(); 
  tts.setPitchRange(0);
  stroke(0);
  frameRate(10); // Slow it down a little
  s = new Server(this, 12340); // Start a simple server on a port
  println(s.ip());
}

void draw() {
  background(0);
  try {
    if (done) {
      c.write("#");
    }
    done=false;
    c = s.available();
    if (c != null) {
      inputS = c.readStringUntil('#');
      c.clear();
      inputs = inputS.split(",");
      input=inputs[0];
      inputS="";
      text(input, 5, 5, 95, 95);
      println(input);
      tts.speak(input);
      done=true;
    }
  }
  catch(Exception e) {
    println("error");
  }
  text(input, 5, 5, 95, 95);
}