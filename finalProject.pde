import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;

String myString = null;
Serial myPort;

int NUM_OF_VALUES = 4;   /** YOU MUST CHANGE THIS ACCORDING TO YOUR PROJECT **/
int[] sensorValues;      /** this array stores values from Arduino **/

float maxDistance = 30;

/* VISUALS */

float angle = 0;

int w, h;
float incr, incr2, incr3;
float centerAngle = 0;
float centerStart = 0;
float centerIncr = 0.1;
int centerBandI=0;
float xoff, yoff, zoom;


/* ANIMATE */

float centerRad = 150; // size
float aniRad = 0;

float boxSize = 110; 
float animateBoxSize = 0;
float animateBoxPos = 0;
float boxPos = -100;
float shootBox, shootBox2;

float triSize = 100; 
float animateTriSize = 0;
float animateTriPos = 0;
float triPos = -10;
float shootTri, shootTri2;

/* HUES */
color bgColor = #000000; // #03083a
color triColor = 255;
color boxColor = 255;

/* AUDIO */
Minim minim;

AudioPlayer bg;
FFT bgFFT;
FFT bgFFTAvg;

/* ASSETS */

String[] assetNames = {"beat", "twinkly", "womp", "ambience"};

/* LOAD ASSETS */

ArrayList<AudioPlayer> beats = new ArrayList<AudioPlayer>();
ArrayList<FFT> beatsFFT = new ArrayList<FFT>();

ArrayList<AudioPlayer> twinklys = new ArrayList<AudioPlayer>();
ArrayList<FFT> twinklysFFT = new ArrayList<FFT>();

ArrayList<AudioPlayer> womps = new ArrayList<AudioPlayer>();
ArrayList<FFT> wompsFFT = new ArrayList<FFT>();

ArrayList<AudioPlayer> ambiences = new ArrayList<AudioPlayer>();
ArrayList<FFT> ambiencesFFT = new ArrayList<FFT>();

/* CURRENT ASSET PLAYING */

/* 

ArrayList of all the current assets playing in the every line
index -1 = none
index 0 = beats
index 1 = twinklys
index 2 = womps
index 3 = ambiences

*/
ArrayList<AudioPlayer> currentAssets = new ArrayList<AudioPlayer>();  

/* 

index of what current beat, twinkly, womp, and ambience that is playing

*/

int currentBeat = -1;
int prevBeat = -1;
int currentTwinkly = -1;
int prevTwinkly = -1;
int currentWomp = -1;
int prevWomp = -1;
int currentAmbience = -1;
int prevAmbience = -1;


void setup() {
  
  fullScreen(P3D);
  w = displayWidth;
  h = displayHeight;
  //size(600, 600, P3D);
  //w = width;
  //h = height;
  
  setupSerial();
  
  shootBox = -w*6;
  shootBox2 = -w*9;
  shootTri = -w*6;
  shootTri2 = -w*9;
  
  /* AUDIO */
  minim = new Minim(this);
  
  /* INSTANTIATING AUDIOPLAYER AND FFT OBJECTS TO ELEMENTS IN ARRAY */
  bg = minim.loadFile("audio/background.wav", 1024);
  bg.loop();
  bgFFT = new FFT(bg.bufferSize(), bg.sampleRate());
  
  for (int i=0;i < 3;i++) {
    beats.add(minim.loadFile("audio/" + assetNames[0] + i + ".mp3"));
    AudioPlayer theBeat = beats.get(i);
    beatsFFT.add(new FFT(theBeat.bufferSize(), theBeat.sampleRate()));
      twinklys.add(minim.loadFile("audio/" + assetNames[1] + i + ".mp3"));
      AudioPlayer theTwinkly = twinklys.get(i);
      twinklysFFT.add(new FFT(theTwinkly.bufferSize(), theTwinkly.sampleRate()));
      womps.add(minim.loadFile("audio/" + assetNames[2] + i + ".mp3"));
      AudioPlayer theWomp = womps.get(i);
      wompsFFT.add(new FFT(theWomp.bufferSize(), theWomp.sampleRate()));
      ambiences.add(minim.loadFile("audio/" + assetNames[3] + i + ".mp3"));
      AudioPlayer theAmbi = ambiences.get(i);
      ambiencesFFT.add(new FFT(theAmbi.bufferSize(), theAmbi.sampleRate()));
    }
}

void draw() {
  updateSerial();
  if (frameCount % 5 == 0) {
    change();
  }
  angle = frameCount;
  background(bgColor);
  createBg();
  createBubbles();
  createEdges();
  createMiniCube();
  createMiniTri();
  createCenter();
  createSpheres();
}

float bubbleSize = 0;
void createBubbles() {
    
  float ambienceBand = 0;
  
  noFill();
  strokeWeight(5);
  if (currentAmbience != -1) {
    bubbleSize = 0;
    FFT ambiAvg = ambiencesFFT.get(currentAmbience);
    ambiAvg.linAverages(100);
    ambiAvg.forward(ambiences.get(currentAmbience).mix);
    ambienceBand = 5*ambiencesFFT.get(currentAmbience).getBand(centerBandI);
    if (currentAmbience == 0) {
      stroke(255, 178, 56,255/3);
    }
    else if (currentAmbience == 1) {
      stroke(174, 111, 237, 255/3);
    }
    else if (currentAmbience == 2) {
      stroke(179, 229, 114, 255/3);
    }
    if (bubbleSize != 200) {
      bubbleSize += 50;
    }
  }
  else {
    stroke(255,255,255,255/3);
    bubbleSize += 200;
  }
  ellipse(w/6,h/2,bubbleSize+ambienceBand, bubbleSize+ambienceBand);
  ellipse(5*w/6,h/2,bubbleSize+ambienceBand, bubbleSize+ambienceBand);
}

void createSpheres() {
  float bgBand = bgFFT.getBand(centerBandI);
  float size = 50 + bgBand;
  noStroke();
  fill(60,60,60,255/2); 
  rotateX(0);
  rotateY(radians(angle));
  rotateZ(0);
  translate(-(w/2),0,0);
  sphere(size);
  translate(w,0,0);
  sphere(size);
}

void createEdges() {
  noStroke();
  fill(255);
  for(int i = 0; i < bgFFT.specSize(); i++) {
    float sumBands = bgFFT.getBand(i);
    if (currentBeat != -1) {
      sumBands += beatsFFT.get(currentBeat).getBand(i);
      if (currentBeat == 0) {
        fill(#ff01b3);
      }
      else if (currentBeat == 1) {
        fill(#ffff00);
      }
      else if (currentBeat == 2) {
        fill(#02ffa6);
      }
    }
    if (currentTwinkly != -1) {
      sumBands += twinklysFFT.get(currentTwinkly).getBand(i);
    }
    if (currentWomp != -1) {
      sumBands += wompsFFT.get(currentWomp).getBand(i);
    }
    if (currentAmbience != -1) {
      sumBands += ambiencesFFT.get(currentAmbience).getBand(i);
    }
    // draw the line for frequency band i, scaling it up a bit so we can see it
    float fftY = map(sumBands, 0, 1024, h, 0);
    rect(i*20,fftY, 20 - 2, h - fftY);
    rect(w-(i*20), 0, 20 - 2, h-fftY);
  }
}

void createMiniTri() {
  centerBandI=0;
  stroke(bgColor);
  strokeWeight(2);
  
  if (currentTwinkly != -1) {
    FFT twinklyAvg = twinklysFFT.get(currentTwinkly);
    twinklyAvg.linAverages(100);
    twinklyAvg.forward(twinklys.get(currentTwinkly).mix);
    float twinklyBand = twinklyAvg.getBand(centerBandI);
    triSize = map(twinklyBand, 0, 100, 100, 200);
    if (twinklyBand < 10 && currentTwinkly == 0) {
      float r= random(0, 50);
      triColor = color(random(150,200),r,r);
    }
    else if (twinklyBand < 10 && currentTwinkly == 1) {
      float r3= random(50, 100);
      triColor = color(random(150,200),r3,r3);
    }
    else if (twinklyBand > 30 && currentTwinkly == 2) {
      float r2= random(100, 150);
      triColor = color(random(150,200),r2,r2);
    }
    if (twinklyBand > 0.125) {
      stroke(random(100,255),random(100,255),random(100,255));
    }
  }
  else {
    triColor = 255;
    triSize = 100;
  }

  if (animateTriPos != triPos) {
    if (triPos - animateTriPos > 0) {
      animateTriPos+=2;
    }
    else if (triPos - animateTriPos < 0) {
      animateTriPos-=2;
    }
  }
  
  if (animateTriSize != triSize) {
     if (triSize - animateTriSize > 0) {
       animateTriSize+=0.0005;
     }
     else {
       animateTriSize-=0.0005;
     }
  }
  
  fill(triColor);
  pushMatrix();
  shootTri+=40;
  if (shootTri > (w/3)+triSize) {
    shootTri = -w*6;
  }
  translate(w/2, (h/4)+animateTriPos, shootTri);
  rotateX(radians(angle));
  rotateY(radians(angle));
  rotateZ(radians(angle));
  createTriangle(triSize);
  popMatrix();
  
  pushMatrix();
  shootTri2+=40;
  if (shootTri2 > (w/3)+triSize) {
    shootTri2 = -w*6;
  }
  translate(w/2, ((3*h)/4)+animateTriPos, shootTri2);
  rotateX(radians(angle));
  rotateY(radians(angle));
  rotateZ(radians(angle));
  createTriangle(triSize);
  popMatrix();
  
}

void createTriangle(float triSize) {
  beginShape(TRIANGLE);
  vertex(-triSize, -triSize, -triSize);
  vertex( triSize, -triSize, -triSize);
  vertex(   0,    0,  triSize);
  
  vertex(triSize, -triSize, -triSize);
  vertex( triSize, triSize, -triSize);
  vertex(   0,    0,  triSize);
  
  vertex(triSize, triSize, -triSize);
  vertex( -triSize, triSize, -triSize);
  vertex(   0,    0,  triSize);
  
  vertex(-triSize, triSize, -triSize);
  vertex( -triSize, -triSize, -triSize);
  vertex(   0,    0,  triSize);
  endShape();
}

void createMiniCube() {
  stroke(bgColor);
  strokeWeight(2);
  if (currentWomp != -1) {
    FFT wompAvg = wompsFFT.get(currentWomp);
    wompAvg.linAverages(50);
    wompAvg.forward(womps.get(currentWomp).mix);
    float wompBand = wompAvg.getBand(centerBandI);
    boxSize = map(wompBand, 0, 50, 100, 150);
    if (wompBand > 20 && currentWomp == 0) {
      float r = random(0, 50);
      boxColor = color(r,r,random(150,200));
    }
    else if (wompBand > 20 && currentWomp == 1) {
      float r2 = random(50,100);
      boxColor = color(r2,r2,random(150,200));
    }
    else if (wompBand > 20 && currentWomp == 2) {
      float r3 = random(100,150);
      boxColor = color(r3,r3,random(150,200));
    }
    if (wompBand < 0.3) {
      stroke(random(100,255),random(100,255),random(100,255));
    }
  }
  else {
    boxColor =255;
    boxSize = 100;
  }
  
  if (animateBoxPos != boxPos) {
    if (boxPos - animateBoxPos > 0) {
      animateBoxPos+=10;
    }
    else if (boxPos - animateBoxPos < 0) {
      animateBoxPos-=10;
    }
    else {
      boxPos *= -1;
    }
  }
  
  fill(boxColor);
  // BOX 1
  pushMatrix();
  shootBox+=30;
  if (shootBox > (w/3)+boxSize) {
    shootBox = -w*6;
  }
  translate(w/4, (h/2)-animateBoxPos, shootBox);
  rotateX(radians(angle));
  rotateY(radians(angle));
  rotateZ(radians(angle));
  box(boxSize);
  popMatrix();
  
  // BOX 2
  pushMatrix();
  shootBox2+=40;
  if (shootBox2 > (w/3)+boxSize) {
    shootBox2 = -w*6;
  }
  translate((3*w)/4, (h/2)+animateBoxPos, shootBox2);
  rotateX(radians(angle));
  rotateY(radians(angle));
  rotateZ(radians(angle));
  box(boxSize);
  popMatrix();
}

void createBg() {
  if (currentBeat != -1) {
    FFT beatAvg = beatsFFT.get(currentBeat);
    beatAvg.linAverages(50);
    beatAvg.forward(beats.get(currentBeat).mix);
    for (int j=0;j < beatsFFT.get(currentBeat).specSize();j++) {
      if (beatAvg.getBand(j) > 50) {
        if (currentBeat == 0) {
          bgColor = color(random(0,35));
        }
        else if (currentBeat == 1) {
          bgColor = color(color(random(35, 70)));
        }
        else {
          bgColor = color(random(0, 60), random(0,60), random(0, 60));
        }
      }
    }
  }
  else {
    bgColor = 0;
  }
}

void createCenter() {
  FFT bgAvg = bgFFT;
  bgAvg.linAverages(10);
  bgAvg.forward(bg.mix);
  centerBandI+=0.05;
  float bgBand = bgAvg.getBand(centerBandI);
  
  // CREATING SHAPE 
  incr+=random(0,0.1);
  incr2+=random(0,0.1);
  incr3+=random(0,0.1);
  translate(w/2,h/2);
  rotateX(radians(angle));
  rotateY(radians(angle));
  rotateZ(radians(angle));
  pushMatrix();
  for(float i=0;i < 10;i++) {
      rotateX(radians(PI*incr));
      rotateY(radians(PI*incr3));
      rotateZ(radians(PI*incr2));
      beginShape();
      zoom -= 0.1;
      float yoff = zoom;
      for (centerAngle=centerStart; centerAngle < (2*PI)+centerStart;centerAngle+=0.02) {
        float bandPos = bgBand * (4*sin(centerAngle));
        float rad = map(noise(xoff, yoff), 0, 1, -10-bandPos, 10+bandPos);
        if (aniRad != centerRad) {
          if (centerRad - aniRad > 0) {
            aniRad+=0.0005;
          }
          else {
            aniRad-=0.0005;
          }
        }
        float centerX = aniRad * cos(centerAngle);
        float centerY = aniRad * sin(centerAngle);
        stroke(255,255,255,255/2);
        strokeWeight(3);
        noFill();
        vertex(centerX+rad, centerY+rad, rad);
        xoff+=0.1;
      }
      yoff+=0.1;
      endShape();
    }
  popMatrix();
  xoff=0;
  zoom=0;
  
  if (frameCount % 500 == 0) {
    centerRad=random(100,w/5);
  }
  box((aniRad*2)+40);
  
  // END SHAPE
}


void setupSerial() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[5], 115200);
  // WARNING!
  // You will definitely get an error here.
  // Change the PORT_INDEX to 0 and try running it again.
  // And then, check the list of the ports,
  // find the port "/dev/cu.usbmodem----" or "/dev/tty.usbmodem----" 
  // and replace PORT_INDEX above with the index number of the port.

  myPort.clear();
  // Throw out the first reading,
  // in case we started reading in the middle of a string from the sender.
  myString = myPort.readStringUntil( 10 );  // 10 = '\n'  Linefeed in ASCII
  myString = null;

  sensorValues = new int[NUM_OF_VALUES];
}



void updateSerial() {
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil( 10 ); // 10 = '\n'  Linefeed in ASCII
    if (myString != null) {
      String[] serialInArray = split(trim(myString), ",");
      if (serialInArray.length == NUM_OF_VALUES) {
        for (int i=0; i<serialInArray.length; i++) {
          sensorValues[i] = int(serialInArray[i]);
        }
      }
    }
  }
}

void change() {
  /* BEATS */
 
 float sensor1 = sensorValues[0];
 float sensor2 = sensorValues[1];
 float sensor3 = sensorValues[2];
 float sensor4 = sensorValues[3];
 float level1 = 6;
 float level2 = 13;
 float level3 = 20;
 
 AudioPlayer cb;
 AudioPlayer cw;
 AudioPlayer ct;
 AudioPlayer ca;
 
 if (currentBeat != -1) {
   if (sensor1 == 0.0) {
     cb = beats.get(currentBeat);
     cb.pause();
     cb.rewind();
     prevBeat = currentBeat;
     currentBeat = -1;
    }
 }
 
 if (Math.abs(level1 - sensor1) < 3) {
   prevBeat = currentBeat;
   currentBeat = 0;
 }
 else if (Math.abs(level2 - sensor1) < 3) {
   prevBeat = currentBeat;
   currentBeat = 1;
 }
 else if (Math.abs(level3 - sensor1) < 3) {
   prevBeat = currentBeat;
   currentBeat = 2;
 }
 else {
   prevBeat = currentBeat;
   currentBeat= -1;
 }
 
 if (currentBeat == -1 || prevBeat != currentBeat) {
   if (currentBeat > -1) { 
     cb = beats.get(currentBeat);
     if (!cb.isPlaying()) {
         cb.loop();
     }
   }
   if (prevBeat != -1) {
     if (beats.get(prevBeat).isPlaying()) {
       beats.get(prevBeat).pause();
       beats.get(prevBeat).rewind();
     }
   }
 }
 
 if (currentWomp != -1) {
   if (sensor2 == 0.0) {
     cw = womps.get(currentWomp);
     cw.pause();
     cw.rewind();
     prevWomp = currentWomp;
     currentWomp = -1;
    }
 }
 
 if (Math.abs(level1 - sensor2) < 3) {
   prevWomp = currentWomp;
   currentWomp = 0;
 }
 else if (Math.abs(level2 - sensor2) < 3) {
   prevWomp = currentWomp;
   currentWomp = 1;
 }
 else if (Math.abs(level3 - sensor2) < 3) {
   prevWomp = currentWomp;
   currentWomp = 2;
 }
 else {
   prevWomp = currentWomp;
   currentWomp= -1;
 }
 
 if (currentWomp == -1 || prevWomp != currentWomp) {
   if (currentWomp > -1) { 
     cw = womps.get(currentWomp);
     if (!cw.isPlaying()) {
         cw.loop();
     }
   }
   if (prevWomp != -1) {
     if (womps.get(prevWomp).isPlaying()) {
       womps.get(prevWomp).pause();
       womps.get(prevWomp).rewind();
     }
   }
 }
 
 if (currentTwinkly != -1) {
   if (sensor3 == 0.0) {
     ct = twinklys.get(currentTwinkly);
     ct.pause();
     ct.rewind();
     prevTwinkly = currentTwinkly;
     currentTwinkly = -1;
    }
 }
 
 if (Math.abs(level1 - sensor3) < 3) {
   prevTwinkly = currentTwinkly;
   currentTwinkly = 0;
 }
 else if (Math.abs(level2 - sensor3) < 3) {
   prevTwinkly = currentTwinkly;
   currentTwinkly = 1;
 }
 else if (Math.abs(level3 - sensor3) < 3) {
   prevTwinkly = currentTwinkly;
   currentTwinkly = 2;
 }
 else {
   prevTwinkly = currentTwinkly;
   currentTwinkly= -1;
 }
 
 if (currentTwinkly == -1 || prevTwinkly != currentTwinkly) {
   if (currentTwinkly > -1) { 
     ct = twinklys.get(currentTwinkly);
     if (!ct.isPlaying()) {
         ct.play();
     }
   }
   if (prevTwinkly != -1) {
     if (twinklys.get(prevTwinkly).isPlaying()) {
       twinklys.get(prevTwinkly).pause();
       twinklys.get(prevTwinkly).rewind();
     }
   }
 }
 
 if (currentAmbience != -1) {
   if (sensor4 == 0.0) {
     ca = ambiences.get(currentAmbience);
     ca.pause();
     ca.rewind();
     prevAmbience = currentAmbience;
     currentAmbience = -1;
    }
 }
 
 if (Math.abs(level1 - sensor4) < 3) {
   prevAmbience = currentAmbience;
   currentAmbience = 0;
 }
 else if (Math.abs(level2 - sensor4) < 3) {
   prevAmbience = currentAmbience;
   currentAmbience = 1;
 }
 else if (Math.abs(level3 - sensor4) < 3) {
   prevAmbience = currentAmbience;
   currentAmbience = 2;
 }
 else {
   prevAmbience = currentAmbience;
   currentAmbience= -1;
 }
 
 if (currentAmbience == -1 || prevAmbience != currentAmbience) {
   if (currentAmbience > -1) { 
     ca = ambiences.get(currentAmbience);
     if (!ca.isPlaying()) {
         ca.play();
     }
   }
   if (prevAmbience != -1) {
     if (ambiences.get(prevAmbience).isPlaying()) {
       ambiences.get(prevAmbience).pause();
       ambiences.get(prevAmbience).rewind();
     }
   }
 }
 
 
 
}
