function [ posX, posY ] = pixelToSpaceCoordinates( resolution, size )
% Input:
%
%   resolution:     [width, height] Resolution of the layer in pixels
%   size:           [width, height] Size of the layer in mm
%   origin:         [x, y, z] The origin of the light field. Output coordinates will
%                   be adjusted to this reference point. Only x and y are
%                   used to compute the new coordinates.
%
% Output:
%   
%   posX:                
%   posY:           

% Normally, the pixel is square, so the entries of sizeOfPixel will be the
% same.
sizeOfPixel = size ./ resolution;

posX = 0.5 * sizeOfPixel(1) : sizeOfPixel(1) : size(1) - 0.5 * sizeOfPixel(1);
posY = 0.5 * sizeOfPixel(2) : sizeOfPixel(2) : size(2) - 0.5 * sizeOfPixel(2);

% Shift for new coordinate system (origin)
posX = posX - size(1)/2;
posY = posY - size(2)/2;

end

