settings.outformat = "pdf";
unitsize(1cm);
size(10cm);

real dL = 4;	// Layer distance
real aW = 12;	// Plane width
real lW = 10; 	// Layer width

// Labels for planes
Label x = Label("$x$", position = EndPoint);
Label s1 = Label("$s^1$", position = EndPoint);
Label s2 = Label("$s^2$", position = EndPoint);

// Sensor plane
path sensorAxis = (-aW/2, 0) -- (aW/2, 0);
draw(sensorAxis, arrow = ArcArrow(SimpleHead), L = x);
// Layers
path layer1Axis = (-aW/2, dL/2) -- (aW/2, dL/2);
path layer2Axis = (-aW/2, -dL/2) -- (aW/2, -dL/2);
draw(layer1Axis, arrow = ArcArrow(SimpleHead), L = s1);
draw(layer2Axis, arrow = ArcArrow(SimpleHead), L = s2);

// Layer pixel squares
real rL = 12; 		// Layer resolution
real psL = lW / rL;	// Pixel size
real start = -lW/2 + psL/2;

for (int i = 0; i < rL; ++i){
	draw(shift(start + i*psL, -dL/2) * box((-psL/2, -psL/2), (psL/2, psL/2)));
	draw(shift(start + i*psL, dL/2) * box((-psL/2, -psL/2), (psL/2, psL/2)));
}

// Sensor pixel squares
real rS = 12; 		// Sensor resolution
real psS = lW / rS;	// Pixel size
real start = -lW/2 + psS/2;

for (int i = 0; i < rS; ++i){
	draw(shift(start + i*psS, 0) * box((-psS/2, -psS/2), (psS/2, psS/2)));
}

// Rays
real slope = -(dL/2)/psS;
real upperXstep = -2.2*psS;
real lowerXstep = 1.5*psS;
path upperRayPart = (0, 0) -- (upperXstep, upperXstep*slope);
path lowerRayPart = (0, 0) -- (lowerXstep, lowerXstep*slope);

for (int i = 0; i < rS; ++i){
	draw(shift(start + i*psS, 0) * upperRayPart, grey, arrow = ArcArrow(SimpleHead));
	draw(shift(start + i*psS, 0) * lowerRayPart, grey);
}

// Red ray
real i = 5;
path upperRedRay = shift(start + i*psS, 0) * upperRayPart;
path lowerRedRay = shift(start + i*psS, 0) * lowerRayPart;
draw(upperRedRay, red, arrow = ArcArrow(SimpleHead));
draw(lowerRedRay, red);

// Intersections of red ray with layers and sensor
real[] intersectionL1 = intersect(layer1Axis, upperRedRay);
real[] intersectionL2 = intersect(layer2Axis, lowerRedRay);
real[] intersectionS = intersect(sensorAxis, upperRedRay);

pair i1 = point(layer1Axis, intersectionL1[0]);
pair i2 = point(layer2Axis, intersectionL2[0]);
pair i3 = point(sensorAxis, intersectionS[0]);

Label labelI1 = Label("$s^1_5$", align = 3*N + 0.5*E);
Label labelI2 = Label("$s^2_7$", align = 3*N + 0.5*E);
Label labelI3 = Label("$x^i_6$", align = 3*N + 0.5*E);

dot(i1, red, L = labelI1);
dot(i2, red, L = labelI2);
dot(i3, red, L = labelI3);

// Angle label
Label arcLabel = Label("$\theta_i$", align = NW - 0.2 * W, p = fontsize(10pt));
real i = 10;
pair arcCenter = (start + i*psS, dL/2); 
real arcRadius = 1.7;
real angle = aTan(1/slope);
path arc = arc(arcCenter, arcRadius, 90, 90 - angle);
draw(arcCenter -- arcCenter + (0, arcRadius + 0.1), L = arcLabel);
draw(arc, arrow = ArcArrow(SimpleHead));

// Layer distance marker
Label dLLabel = Label("$d_L$", position = MidPoint);
real markerOffset = 0.5;
draw((-aW/2, dL/2) - (markerOffset, 0) -- (-aW/2, -dL/2) - (markerOffset, 0), bar = Bars, L = dLLabel);
