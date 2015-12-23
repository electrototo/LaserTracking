import SimpleOpenNI.*;
SimpleOpenNI kinect;

void setup(){
  //We have to assure the dimensions are always set to 640 * 480 
  size(640, 480);
  
  kinect = new SimpleOpenNI(this);
  
  kinect.enableDepth();
  kinect.enableRGB();
  
  kinect.alternativeViewPointToImage();
}

//========================================//
//|      CALIBRATION STARTS HERE         |//
//========================================//

float distX = 0;
float distY = 0; 
float distZ = 0;

//========================================//
//|       CALIBRATION ENDS HERE         |//
//========================================//

float base;

void draw(){
  kinect.update();
  
  image(kinect.rgbImage(), 0, 0);
  
  int pointer = mouseX + (mouseY * width);
  
  PVector[] depthValaues = kinect.depthMapRealWorld();
  PVector actual = depthValues[pointer];
  
  if(actual.x <= 0){
    base = abs(actual.x) + distX;
  } else if(actual.x <= distX && actual.x > 0){
    base = distX - actual.x;
  } else{
    base = actual.x - distX;
  }
  
  float angle = degrees(atan(actual.z/base));
  
  if(angle < 0) angle = 180 - angle;
  
  textSize(22);
  fill(255, 0, 0);
  text("AngleX: " + angle, mouseX, mouseY);
}
