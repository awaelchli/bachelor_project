function [ u, v ] = pixelToSpaceCoordinates( x, y, resolution, size )
%   x:              Pixel coordinate x
%   y:              Pixel coordinate y
%   resolution:     [width, height] Resolution of the layer in pixels
%   size:           [width, height] Size of the layer in mm

% Normally, the pixel is square, so the entries of sizeOfPixel will be the
% same.
sizeOfPixel = size ./ resolution;

coord = 0.5 * sizeOfPixel + [x, y] .* sizeOfPixel;
u = coord(1);
v = coord(2);
end

