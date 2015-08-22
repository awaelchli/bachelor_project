settings.outformat = "pdf";
unitsize(1cm);
size(8cm);

real planeSize = 8;
int resolution = 15;
real pS = planeSize / resolution;
int tileResolution = 7;
real tileSize = tileResolution * pS;
int overlap = 2;

// Parent plane
path plane = scale(planeSize) * box((-0.5, -0.5), (0.5, 0.5));
pen gridColor = black;
draw(plane, gridColor);

// Pixel grid of parent plane
real yStart = planeSize / 2;
real xStart = -planeSize / 2;
for(int y = 0; y < resolution; ++y){
	path line = (xStart, yStart - y * pS) -- (xStart + planeSize, yStart - y * pS);
	draw(line, gridColor);
}
for(int x = 0; x < resolution; ++x){
	path line = (xStart + x * pS, yStart) -- (xStart + x * pS, yStart - planeSize);
	draw(line, gridColor);
} 

// Tiles
pen p = opacity(0.5, blend = "Darken");
for(int ay = 0; ay < resolution - overlap; ay = ay + tileResolution - overlap){
	for(int ax = 0; ax < resolution - overlap; ax = ax + tileResolution - overlap){
		pen c;
		if((ax + ay) % 2 == 0){
			c = p + gray;
		}else {
			c = p + gray;
		}
		pair anchor = (-planeSize / 2 + ax * pS, planeSize / 2 - ay * pS);
		path tile = shift(anchor) * scale(tileSize) * box((0,0), (1, -1));
		fill(tile, c);
	}
}

// Markers
real offset = pS;

Label L1 = Label("$r_x$", position = MidPoint, N);
Label L2 = Label("$o_x$", position = MidPoint, N);
Label L3 = Label("$R_x$", position = MidPoint, S);
Label L4 = Label("$r_y$", position = MidPoint, W);
Label L5 = Label("$o_y$", position = MidPoint, W);
Label L6 = Label("$R_y$", position = MidPoint, E);

path tileMarker1 = (xStart, yStart + offset) -- (xStart + tileSize, yStart + offset);
path tileMarker2 = (xStart - offset, yStart) -- (xStart - offset, yStart - tileSize);
path offsetMarker1 = (xStart + tileSize - overlap * pS, yStart + 2 * offset) -- (xStart + tileSize, yStart + 2 * offset);
path offsetMarker2 = (xStart - 2 * offset, yStart - tileSize + overlap * pS) -- (xStart - 2 * offset, yStart - tileSize);
path planeMarker1 = (-planeSize / 2, -planeSize / 2 - 3 * offset) -- (planeSize / 2, -planeSize / 2 - 3 * offset);
path planeMarker2 = (planeSize / 2 + 3 * offset, planeSize / 2) -- (planeSize / 2 + 3 * offset, -planeSize / 2);

draw(tileMarker1, bar = Bars, L = L1);
draw(tileMarker2, bar = Bars, L = L4);
draw(offsetMarker1, bar = Bars, L = L2);
draw(offsetMarker2, bar = Bars, L = L5);
draw(planeMarker1, bar = Bars, L = L3);
draw(planeMarker2, bar = Bars, L = L6);