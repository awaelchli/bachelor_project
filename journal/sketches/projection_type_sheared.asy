settings.outformat = "pdf";
unitsize(1cm);
size(6cm);

real z = 6;		// Camera plane distance
real aW = 12;	// Axis width
real w = 10; 	// Width of common focal plane
real f = 1; 	// Focal length

pair[] focalPlaneEndPoints = {(-w/2, 0), (w/2, 0)};

// Labels for planes
Label u = Label("$u$", position = EndPoint);
Label x = Label("$x$", position = EndPoint);
Label s = Label("$s$", position = EndPoint);

// Camera plane
draw((-aW/2, z) -- (aW/2, z), arrow = ArcArrow(SimpleHead), L = u);
// Common focal plane
path focalPlane = (-aW/2, 0) -- (aW/2, 0);
path commonFocalPlane = (focalPlaneEndPoints[0] -- focalPlaneEndPoints[1]);
draw(focalPlane, arrow = ArcArrow(SimpleHead), L = s);
draw(commonFocalPlane, red);
// Sensor plane
path sensorAxis = (-aW/2, z - f) -- (aW/2, z - f);
draw(sensorAxis, arrow = ArcArrow(SimpleHead), L = x);

// Camera positions
pair cam1 = (-4, z);
pair cam2 = (0, z);
pair cam3 = (4, z);

// Camera viewing zones
path v1 = cam1 -- focalPlaneEndPoints[0];
path v2 = cam1 -- focalPlaneEndPoints[1];
path v3 = cam2 -- focalPlaneEndPoints[0];
path v4 = cam2 -- focalPlaneEndPoints[1];
path v5 = cam3 -- focalPlaneEndPoints[0];
path v6 = cam3 -- focalPlaneEndPoints[1];
draw(v1, dotted);
draw(v2, dotted);
draw(v3, dotted);
draw(v4, dotted);
draw(v5, dotted);
draw(v6, dotted);

// Intersections of camera viewing zones with sensor axis
real[] i1 = intersect(sensorAxis, v1);
real[] i2 = intersect(sensorAxis, v2);
real[] i3 = intersect(sensorAxis, v3);
real[] i4 = intersect(sensorAxis, v4);
real[] i5 = intersect(sensorAxis, v5);
real[] i6 = intersect(sensorAxis, v6);

draw(subpath(sensorAxis, i1[0], i2[0]), red);
draw(subpath(sensorAxis, i3[0], i4[0]), red);
draw(subpath(sensorAxis, i5[0], i6[0]), red);

// Camera dots
dot(cam1);
dot(cam2);
dot(cam3);