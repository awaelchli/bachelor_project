function [ anglesX, anglesY ] = computeRayAngles( fov, resolution )
%   fov:            Field of View of the camera/lens in radians
%   resolution:     Angular resolution of cameras [pixelsY, pixelsX]

% max = tan(fov / 2);
% angleX = -max + (camX - 1) * 2 * max / (resolution(1) - 1);
% angleY = -max + (camY - 1) * 2 * max / (resolution(2) - 1);

anglesX = 1 : resolution(2);
anglesY = 1 : resolution(1);

anglesX = (anglesX - resolution(2) / 2) * fov / resolution(2);
anglesY = (anglesY - resolution(1) / 2) * fov / resolution(1);

% Relative angles
anglesX = tan(anglesX);
anglesY = tan(anglesY);

end

