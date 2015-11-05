#version 3.7;
// Source: http://commons.wikimedia.org/wiki/File:PNG_transparency_demonstration_1.png
// Modified by Adrian Wälchli, May 2015
global_settings {assumed_gamma 1.0}

#include "colors.inc"
//#include "transforms.inc"  

#declare DistanceBetweenCamerasY = 0.2;
#declare DistanceBetweenCamerasX = 0.2;
#declare DistanceToCameraPlane = 5;
#declare AngularResolutionY = 6;
#declare AngularResolutionX = 6;
#declare FOV_horizontal = 60;
#declare aspectRatio = 1;

// The camera index is between 0 and AngularResolution - 1
#declare CameraIndexX = mod(frame_number, AngularResolutionX);
#declare CameraIndexY = (frame_number - CameraIndexX) / AngularResolutionX;

#declare Look_At = <0, 0, 0>; 

#declare CameraPositionY = ((AngularResolutionY - 1) / 2 - CameraIndexY) * DistanceBetweenCamerasY;             
#declare CameraPositionX = (-(AngularResolutionX - 1) / 2 + CameraIndexX) * DistanceBetweenCamerasX;
        
#declare Shear_Angle_Y = (Look_At.y - CameraPositionY) / DistanceToCameraPlane;
#declare Shear_Angle_X = (Look_At.x - CameraPositionX) / DistanceToCameraPlane;      

//#declare Cam_V = Look_At - <DistanceToCameraPlane, CameraPositionY, CameraPositionX>;

#declare Shear = transform {
   matrix <  1,  0,  -Shear_Angle_X,
             0,  1,  -Shear_Angle_Y,
             0,  0,  1,
             0,  0,  0 >        
}        
        
camera {    
//orthographic
    
    
    location <-DistanceToCameraPlane, CameraPositionY, CameraPositionX>
    look_at Look_At  
    right <0, 0, image_width / image_height>
    angle FOV_horizontal 
    transform Shear 
    //Reorient_Trans(z,<Cam_V.x,0,Cam_V.z>)
   // translate<Look_At.x,0,Look_At.z>
    //look_at Look_At      
  //direction <0, 0, -1>     
  
  
  
  //look_at <0, CameraPositionY, CameraPositionX>
}
 
light_source { <-9, 7, -6> color White }   
light_source { <9, -7, 6> color White }   
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
  sphere { <-.25, .6, .25>, .13 }
  sphere { <.25, .6, -.25>, .13 }
}
 
#declare Middles = union {
  sphere { <-.25, .6, 0>, .13 }
  sphere { <.25, .6, 0>, .13 }
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
 
object { Dice(color rgb <.7, 0, 0>)  rotate <195, -30, 10> translate <-1.0, 0, 0>}//Red
object { Dice(color rgb <0, 0, .7>)  rotate <30,40,50> translate <-0.5,1,1>}//Blue
object { Dice(color rgb <0, .5, 0>)  rotate <-40,20,-120> translate <0.3,1,-1>}//Green
object { Dice(color rgb <.5,.5, 0>)  rotate <-10,290,-30> translate <1,-1,.4>}//Yellow