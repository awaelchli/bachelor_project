settings.outformat = "pdf";
unitsize(1cm);
size(10cm);

real z = 6;		// Camera plane distance
real dL = 1;	// Layer distance
real w = 12;	// Plane width
real lW = 10; 	// Layer width

pair[] layer1 = {(-lW/2, dL), (lW/2, dL)};
pair[] layer2 = {(-lW/2, -dL), (lW/2, dL)};
pair[] sensor = {(-lW/2, 0), (lW/2, 0)};

// Labels for planes
Label u = Label("$u$", position = EndPoint);
Label x = Label("$x$", position = EndPoint);
Label s1 = Label("$s^1$", position = EndPoint);
Label s2 = Label("$s^2$", position = EndPoint);

// Camera plane
draw((-w/2, z) -- (w/2, z), arrow = ArcArrow(SimpleHead), L = u);
// Sensor plane
draw((-w/2, 0) -- (w/2, 0), arrow = ArcArrow(SimpleHead), L = x);
// Layers
draw((-w/2, dL) -- (w/2, dL), arrow = ArcArrow(SimpleHead), L = s1);
draw((-w/2, -dL) -- (w/2, -dL), arrow = ArcArrow(SimpleHead), L = s2);

// Camera positions
pair cam1 = (-4, z);
pair cam2 = (0, z);
pair cam3 = (4, z);

// Layer bounding markers
real mS = 0.1; 	// Marker size
draw((-lW/2, mS) -- (-lW/2, -mS));
draw((lW/2, mS) -- (lW/2, -mS));
draw((-lW/2, mS + dL) -- (-lW/2, -mS + dL));
draw((lW/2, mS + dL) -- (lW/2, -mS + dL));
draw((-lW/2, mS - dL) -- (-lW/2, -mS - dL));
draw((lW/2, mS - dL) -- (lW/2, -mS - dL));

// Camera viewing zones
draw(cam1 -- sensor[0], dotted);
draw(cam1 -- sensor[1], dotted);
draw(cam2 -- sensor[0], dotted);
draw(cam2 -- sensor[1], dotted);
draw(cam3 -- sensor[0], dotted);
draw(cam3 -- sensor[1], dotted);

// Layer pixel squares
real rL = 50; 		// Layer resolution
real psL = lW / rL;	// Pixel size
real start = -lW/2 + psL/2;

for (int i = 0; i < rL; ++i){
	draw(shift(start + i*psL, -dL) * box((-psL/2, -psL/2), (psL/2, psL/2)), grey);
	draw(shift(start + i*psL, dL) * box((-psL/2, -psL/2), (psL/2, psL/2)), grey);
}

// Sensor pixel squares
real rS = 30; 		// Sensor resolution
real psS = lW / rS;	// Pixel size
real start = -lW/2 + psS/2;

for (int i = 0; i < rS; ++i){
	draw(shift(start + i*psS, 0) * box((-psS/2, -psS/2), (psS/2, psS/2)), grey);
}

// Ray
int pixel = 10;
pair rayStart = (-lW/2 + psL/2 + pixel * psL, -dL);
draw(rayStart -- cam3, red);

// Camera dots
dot(cam1);
dot(cam2);
dot(cam3);
