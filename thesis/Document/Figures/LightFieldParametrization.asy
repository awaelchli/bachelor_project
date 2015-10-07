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

triple rayStart = 2X;//(2, -0.5, 0.5);
triple rayEnd = -rayStart;
path3 ray = rayStart -- rayEnd;

material m_white = material(diffusepen=gray(0.4), emissivepen=gray(0.6));

draw(ray);

real i1 =  intersect(P = rayStart, Q = rayEnd, X, UVO);
real i2 =  intersect(P = rayStart, Q = rayEnd, X, XYO);

dot(point(ray, i1));
dot(point(ray, i2));

draw(surface(planeUV), m_white);
draw(planeUV);

draw(surface(planeXY), m_white);
draw(planeXY);