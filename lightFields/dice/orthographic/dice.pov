#version 3.7;
// Source: http://commons.wikimedia.org/wiki/File:PNG_transparency_demonstration_1.png
// Modified by Adrian Wälchli, May 2015
global_settings {assumed_gamma 1.0}

#include "colors.inc"  

#declare DistanceBetweenCamerasY = 0.2;
#declare DistanceBetweenCamerasX = 0.2;
#declare DistanceToCameraPlane = 8;
#declare AngularResolutionY = 8;
#declare AngularResolutionX = 8;
#declare aspectRatio = image_width / image_height;

// The camera index is between 0 and AngularResolution - 1
#declare CameraIndexX = mod(frame_number, AngularResolutionX);
#declare CameraIndexY = (frame_number - CameraIndexX) / AngularResolutionX; 

#declare CameraPositionY = ((AngularResolutionY - 1) / 2 - CameraIndexY) * DistanceBetweenCamerasY;             
#declare CameraPositionX = (-(AngularResolutionX - 1) / 2 + CameraIndexX) * DistanceBetweenCamerasX;

#declare CameraPosition = <CameraPositionX, CameraPositionY, -DistanceToCameraPlane>;
#declare Look_At = <0, 0, 0>;
#declare Sensor_Height = 5;
 
camera {    
  orthographic 
  location CameraPosition  
  up y * Sensor_Height
  right x * Sensor_Height * aspectRatio
  direction Look_At - CameraPosition     
}
                                     
light_source { <-6, 7, -9> color White }   
light_source { <6, -7, 9> color White }   
background { color White }
 
#declare DiceColor = color red 1 green .95 blue .65;
#declare DotColor = color red .1 green .1 blue .1;
 
 
#declare DiceBody = intersection {
  box { <-1, -1, -1>, <1, 1, 1> scale 0.5 }
  superellipsoid { <0.7, 0.7>  scale .63 }
}
 
#declare Middle = sphere { <0, .6, 0>, .13}
 
#declare Corners1 = union {
  sphere { <-.25, .6, -.25>, .13 }
  sphere { <.25, .6, .25>, .13 }
}
 
#declare Corners2 = union { 
  sphere { <.25, .6, -.25>, .13 }
  sphere { <-.25, .6, .25>, .13 }
}
 
#declare Middles = union { 
  sphere { <0, .6, -.25>, .13 }
  sphere { <0, .6, .25>, .13 }
}
 
#declare One = Middle
 
#declare Two = Corners1
 
#declare Three = union {
  object { Middle }
  object { Corners1 }
}
 
#declare Four = union {
  object { Corners1 }
  object { Corners2 }
}
 
#declare Five = union {
  object { Four }
  object { One }
}
 
#declare Six = union {
  object { Corners1 }
  object { Corners2 }
  object { Middles }
}
 
#declare DiceInterior = interior { ior 1.5 }
#declare DiceFinish = finish { phong 0.1 specular 0.5 ambient .4 }
 
#macro Dice(Color)
difference {
  object {
    DiceBody
    pigment { color Color filter 0.4 transmit 0.3}
    interior { DiceInterior }
    finish { DiceFinish }
  }
  union {
    object { One rotate -90*z }
    object { Two }
    object { Three rotate -90*x }
    object { Four rotate 90*x }
    object { Five rotate 180*x }
    object { Six rotate 90*z }
    pigment { White }
    finish { ambient 0.5 roughness 0.5}
 
  }
  bounded_by { box { <-.52, -.52, -.52>, <.52, .52, .52> } }
}
#end

object { Dice(color rgb <.7, 0, 0>)  rotate <10, -30, 195> translate <0, 0, -1>} //Red
object { Dice(color rgb <0, 0, .7>)  rotate <50, 40, 30> translate <1, 1, -0.5>} //Blue
object { Dice(color rgb <0, .5, 0>)  rotate <-120, 20, -40> translate <-1, 1, 0.3>} //Green
object { Dice(color rgb <.5,.5, 0>)  rotate <-30, 290, -10> translate <0.4, -1, 1>} //Yellow
   
/*   
polygon {
    4,
    <0, 0>, <0, 1>, <1, 1>, <1, 0>
    texture {
        finish { ambient 1 diffuse 0 }
    }
    translate <-0.5, -0.5, 0>
    scale y * Sensor_Height / 2
    scale x * Sensor_Height * aspectRatio / 2
}
*/
