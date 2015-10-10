settings.outformat = "pdf";
settings.prc = false;
settings.render = 8;
size(0, 200);
size3(200);
import three;
import math;

currentlight = light(white, (2, 2, 2), (2, -2, -2));

draw(O--X, L = Label("$x$"), red);

real d = 1.2;

triple UVO = d / 2 * X - Y / 2 - Z / 2;
triple XYO = - d / 2 * X - Y / 2 - Z / 2;

path3 planeUV = plane(O = UVO, Y, Z);
path3 planeXY = plane(O = XYO, Y, Z);

triple rayStart = (1.2, -0.5, 0.5);
triple rayEnd = -rayStart;
path3 ray = rayStart -- rayEnd;

material m_white = material(diffusepen=gray(0.4), emissivepen=gray(0.6));

draw(ray, L = Label("$L(u, v, s, t)$", position = EndPoint));
draw(ray, EndArrow3);

real i1 =  intersect(P = rayStart, Q = rayEnd, X, UVO);
real i2 =  intersect(P = rayStart, Q = rayEnd, X, XYO);

triple p1 = point(ray, i1);
triple p2 = point(ray, i2);

dot(p1, L = Label("$(u, v)$"));
dot(p2, L = Label("$(s, t)$"));

draw(surface(planeUV), m_white);
draw(planeUV);

draw(surface(planeXY), m_white);
draw(planeXY);