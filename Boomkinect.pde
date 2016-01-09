//Falta arreglar para que se ajuste conforme la profundidad...

import SimpleOpenNI.*;
import processing.serial.*;

Serial pan;
Serial tilt;

SimpleOpenNI kinect;


//Defining variables for servo separation (in millimeters)
float sepX = -288;      //150
float sepY = 400;
float sepZ = 50;

//Text printing options
int sizeT = 16;
int sepT = 3;
boolean info = true;
boolean boundaries = true;

//Defining variables to determine if x is negative or not
boolean left = true; //left for the kinect, right for the image displayed on computer's screen
boolean up = true;

//Variables for storing angles and base of the "triangles"
float baseX;
float angleX;

float baseY;
float angleY;

//Error correction
float prevX;
float prevY;

void setup(){
  kinect = new SimpleOpenNI(this);
  
  pan = new Serial(this, Serial.list()[0], 9600);
  tilt = new Serial(this, Serial.list()[1], 9600);
  
  size(640, 480);
  
  kinect.enableRGB();
  kinect.enableDepth();
  
  kinect.alternativeViewPointDepthToImage();
}

void draw(){
  //Update the kinect and display the RGB image
  kinect.update();
  
  //Flip horizontally the image
  image(kinect.rgbImage(), 0, 0);
  
  //Get the position of the mouse to convert it to an index for its future use
  int pointer = mouseX + (mouseY * 640);
  
  //Obtain the *real* separation from the mouse position to the kinect
  PVector depthValues[] = kinect.depthMapRealWorld();
  
  // aP stands for Actual Point
  PVector aP = depthValues[pointer];
  
  // mouseX operations
  if(aP.x < 0){
    left = false;
  } else {
    left = true;
  }
  
  if(left){
    if(aP.x < sepX){
      baseX = sepX - aP.x;
    } else{
      baseX = aP.x - sepX;
    }
    
    angleX = 90 + degrees(atan(baseX/aP.z));
  } else {
    baseX = abs(aP.x) + sepX;
    angleX = 90 - degrees(atan(baseX/aP.z));
  }
  // end mouseX operations
  
  // mouseY operations
  if(aP.y > 0){
    up = true;
  } else {
    up = false;
  }
  
  if(up){
    if(aP.y < sepY){
      baseY = aP.y - sepY;
      
      if(info){
        text("aP.y < sepY", 5, sizeT*3 + sepT);
      }
    } else {
      baseY = aP.y - sepY;
      if(info){
        text("aP.y >= sepY" , 5, sizeT*3 + sepT);
      }
    }
    
    angleY = 90 + degrees(atan(baseY/aP.z));
  } else {
    baseY = abs(aP.y) + sepY;
    
    angleY = 90 - degrees(atan(baseY/aP.z));
  } 
  
  //Debugging text printing
  if(info){    
    fill(255, 255, 0);
    textSize(sizeT);
    text("y: " + aP.y, mouseX, mouseY);
    text("by: " + baseY, mouseX, mouseY - (sizeT + sepT));
    text("z: " + aP.z, mouseX, mouseY - (sizeT*2 + sepT));
    text("a: " + angleY, mouseX, mouseY - (sizeT*3 + sepT));        //lD = laser Distance
    
    text("Boolean up: " + up, 5, sizeT + sepT);
    text("Boolean left:" + left, 5, sizeT*2 + sepT);
    
    text("mx: " + mouseX, 5, sizeT*4 + sepT);
    text("my: " + mouseY, 5, sizeT*5 + sepT);
  }
  
  if(boundaries){
    fill(255, 0, 0, 126);
    noStroke();
    
    rect(0, 32, 30, 438);
    rect(0, 0, 640, 32);
    rect(615, 32, 25, 438);
    rect(0, 470, 640, 10);
  }
  
  prevX = angleX;
  prevY = angleY;
  
  if(aP.y == 0 || aP.x == 0){
    pan.write(round(prevX));
    tilt.write(round(prevY));
  } else {  
    pan.write(round(angleX)); 
    tilt.write(round(angleY));
  }
  
  delay(10);
}

void keyPressed(){
  switch(key){
    case 'i':
      info = !info;
      break;
    case 'w':
      sepY++;
      break;
    case 's':
      sepY--;
      break;
    case 'a':
      sepX--;
      break;
    case 'd':
      sepX++;
      break;
    case 'b':
      boundaries = !boundaries;
      break;
      
    default:
      break;
  }
}
