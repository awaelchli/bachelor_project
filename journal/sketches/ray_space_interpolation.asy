settings.outformat = "pdf";
unitsize(2cm);
size(10cm);

real layer1y = -1;
real layer2y = 1;
real pS = 1;

// Layer axes
path axis1 = (-1.5 * pS, layer1y) -- (1.5 * pS, layer1y); 
path axis2 = (-1.5 * pS, layer2y) -- (1.5 * pS, layer2y); 
draw(axis1, arrow = ArcArrow(SimpleHead));
draw(axis2, arrow = ArcArrow(SimpleHead));

// Two pixels per layer
pair pC11 = (-pS/2, layer1y);
pair pC12 = (pS/2, layer1y);
pair pC21 = (-pS/2, layer2y);
pair pC22 = (pS/2, layer2y);
draw(shift(pC11) * scale(pS) * box((-0.5, -0.5), (0.5, 0.5)));
draw(shift(pC12) * scale(pS) * box((-0.5, -0.5), (0.5, 0.5)));
draw(shift(pC21) * scale(pS) * box((-0.5, -0.5), (0.5, 0.5)));
draw(shift(pC22) * scale(pS) * box((-0.5, -0.5), (0.5, 0.5)));

// Pixel centers and labels
Label a1 = Label("$a_1$");
Label a11 = Label("$a_1^{\prime}$");
Label a2 = Label("$a_2$");
Label a22 = Label("$a_2^{\prime}$");
dot(pC11, L = a1, N);
dot(pC12, L = a11, N);
dot(pC21, L = a22, N);
dot(pC22, L = a2, N);

// Ray
path ray = (-0.7, -2.5) -- (0.6, 2.5);

// Ray intersections with layers
real[] isection1 = intersect(ray, axis1);
real[] isection2 = intersect(ray, axis2);
pair rayhitL1 = point(ray, isection1[0]);
pair rayhitL2 = point(ray, isection2[0]);
dot(rayhitL1, red);
dot(rayhitL2, red);

// Markers for weights
real mOff = 0.7;
Label w1 = Label("$\omega_1$", MidPoint, 2*N);
Label w11 = Label("$1 - \omega_1$", MidPoint, 2*N);
Label w2 = Label("$1 - \omega_2$", MidPoint, 2*N);
Label w22 = Label("$\omega_2$", MidPoint, 2*N);
draw(shift(0, mOff) * (pC11 -- rayhitL1), blue, L = w1, bar = Bars);
draw(shift(0, mOff) * (rayhitL1 -- pC12), blue, L = w11, bar = Bars);
draw(shift(0, mOff) * (rayhitL2 -- pC22), blue, L = w22, bar = Bars);
draw(shift(0, mOff) * (pC21 -- rayhitL2), blue, L = w2, bar = Bars);

// Draw ray on top of other lines
draw(ray, red, arrow = ArcArrow(SimpleHead));