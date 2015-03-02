function [ angleX, angleY ] = computeRayAngles( camX, camY, fov, resolution )
%   camX:           X coordinate of camera
%   camY:           Y coordinate of camera
%   fov:            Field of View in radians
%   resolution:     Angular resolution of light field [numCamerasX, numCamerasY]

max = tan(fov / 2);
angleX = -max + (camX - 1) * 2 * max / (resolution(1) - 1);
angleY = -max + (camY - 1) * 2 * max / (resolution(2) - 1);
% angleY = max - (camY - 1) * 2 * max / resolution(2);

end

