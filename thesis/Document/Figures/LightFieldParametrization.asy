settings.outformat = "pdf";
settings.prc = false;
settings.render = 0;
size(7cm, 0);
import graph3;
import math;

currentlight=light(white,(2,2,2),(2,-2,-2));
//draw(O--X, blue);
//draw(O--Y, green);
//draw(O--Z, red); 

triple UVO = X - Y / 2 - Z / 2;
triple XYO = -X - Y / 2 - Z / 2;

path3 planeUV = plane(O = UVO, Y, Z);
path3 planeXY = plane(O = XYO, Y, Z);

triple rayStart = (2, -0.5, 0.5);
triple rayEnd = -rayStart;
path3 ray = rayStart -- rayEnd;



draw(ray);

real i1 =  intersect(P = rayStart, Q = rayEnd, X, UVO);
real i2 =  intersect(P = rayStart, Q = rayEnd, X, XYO);

dot(point(ray, i1));
dot(point(ray, i2));
//dot(point(ray, i2[0]));
draw(surface(planeUV), red);
draw(planeXY);