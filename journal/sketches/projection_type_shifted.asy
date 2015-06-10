settings.outformat = "pdf";
unitsize(1cm);
size(6cm);

real z = 6;		// Camera plane distance
real aW = 12;	// Axis width
real w = 6.5; 	// Width of focal plane
real f = 1; 	// Focal length

// Labels for planes
Label u = Label("$u$", position = EndPoint);
Label x = Label("$x$", position = EndPoint);
Label s = Label("$s$", position = EndPoint);

// Camera positions
pair cam1 = (-2, z);
pair cam2 = (0, z);
pair cam3 = (2, z);

// Camera plane
draw((-aW/2, z) -- (aW/2, z), arrow = ArcArrow(SimpleHead), L = u);

// Focal planes
path focalPlaneAxis = (-aW/2, 0) -- (aW/2, 0);
draw(focalPlaneAxis, arrow = ArcArrow(SimpleHead), L = s);
path fp1 = (cam1.x - w/2, 0) -- (cam1.x + w/2, 0);
path fp2 = (cam2.x - w/2, 0) -- (cam2.x + w/2, 0);
path fp3 = (cam3.x - w/2, 0) -- (cam3.x + w/2, 0);
draw(fp1, red);
draw(fp2, red);
draw(fp3, red);

// Sensor plane
path sensorAxis = (-aW/2, z - f) -- (aW/2, z - f);
draw(sensorAxis, arrow = ArcArrow(SimpleHead), L = x);

// Camera viewing zones
path v1 = cam1 -- point(fp1, 0);
path v2 = cam1 -- point(fp1, 1);
path v3 = cam2 -- point(fp2, 0);
path v4 = cam2 -- point(fp2, 1);
path v5 = cam3 -- point(fp3, 0);
path v6 = cam3 -- point(fp3, 1);
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