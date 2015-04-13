function [ angleX, angleY ] = computeRayAngles( camX, camY, fov, resolution )
%   camX:           X coordinate of camera
%   camY:           Y coordinate of camera
%   fov:            Field of View in radians, in X and in Y direction
%   resolution:     Angular resolution of light field [numCamerasX, numCamerasY]

maxX = tan(fov(1) / 2);
maxY = tan(fov(2) / 2);

angleX = -maxX + (camX - 1) * 2 * maxX / (resolution(1) - 1);
angleY = -maxY + (camY - 1) * 2 * maxY / (resolution(2) - 1);

end

