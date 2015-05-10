function [ anglesX, anglesY ] = computeRayAngles( fov, resolution )
%   fov:            [vFov, hFov] Vertical and horizontal field of view of 
%                   the camera/lens in radians
%   resolution:     Spatial resolution of the light field [pixelsY, pixelsX]

% max = tan(fov / 2);
% angleX = -max + (camX - 1) * 2 * max / (resolution(1) - 1);
% angleY = -max + (camY - 1) * 2 * max / (resolution(2) - 1);

anglesX = 1 : resolution(2);
anglesY = 1 : resolution(1);

anglesX = (anglesX - floor(resolution(2) / 2+.5)) * fov(2) / resolution(2);
anglesY = (anglesY - floor(resolution(2) / 2+.5)) * fov(1) / resolution(1);

% Relative angles
anglesX = tan(anglesX);
anglesY = tan(anglesY);

end

