import graph;
import stats;

include "sheared_projections_layers_overview-1.asy";

real window_size = 1.1;
pair point1 = point(ray, isection[0]);
pixel = 10;
real left = -lW/2 + psS * (pixel - 1);
real right = left + psS;
pair center = ((right + left) / 2, 0) - (window_size/2, window_size/2);
real baseline = -0.6;
real offset = 0.35;

// Gaussian weight function
real pS = right - left; 						// Pixel size
pair x_zero = ((right + left) / 2, baseline);	// Zero point on base axis
real sigma = 0.3;
real mu = 0;
real gauss(real x) {return 1 / (sigma * sqrt(2 * pi)) * exp(-0.5 * ((x - mu) / sigma)^2);}
pair G(real x) {return (x, gauss(x));}
real cutoff = -1.2;
guide weight = shift(x_zero) * scale(0.3) * graph(gauss, -cutoff , cutoff);
draw(weight, blue);

// Neighbour functions
draw(shift(-pS) * weight, blue + dotted);
draw(shift(pS) * weight, blue + dotted);
draw(shift(2*pS) * weight, blue + dotted);
draw(shift(-2*pS) * weight, blue + dotted);

// Baseline of weight function
path base = (left - offset, baseline) -- (right + offset, baseline);
draw(base, arrow = ArcArrow(SimpleHead));

// Baseline interval markers
mS = 0.01;
Label minus1 = Label("$-1$", position = BeginPoint);
Label plus1 = Label("$1$", position = BeginPoint);
draw((left, -mS + baseline) -- (left, mS + baseline), L = minus1);
draw((right, -mS + baseline) -- (right, mS + baseline), L = plus1);

// Dotted weight marker line
pair point2 = (point1.x, baseline);
path line = point1 -- point2;
draw(line, dashed); 

// Pixel center dot
pair pc = ((right + left) / 2, 0);
dot(pc);

// Dotted center marker line
draw(pc -- x_zero, dashed);

// Intersection dots
real[] isection = intersect(line, weight);
pair point3 = point(line, isection[0]);
dot(point1, red);
dot(point3, blue);

// Labels and marker for intersections
label("$w\left(d\right)$", point3, NW);
label("$p$", pc, NE);
label("$p'$", point1, NW);
Label d = Label("$d$", MidPoint);
//draw((point2 + (0, mS)) -- (point2 - (0, mS)), L = p);
real offs = 0.04;
draw((point2.x, baseline - offs) -- (x_zero.x, baseline - offs), L = d, bar = Bars);

// Move view to intersection point on the sensor
clip(shift(center - (0, 0.2)) * scale(window_size) * unitsquare);
