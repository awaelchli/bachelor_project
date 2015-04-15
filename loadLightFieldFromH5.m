function [ lightField, channels, focalLength, fov, cameraDist, planeDist ] = loadLightFieldFromH5( path, filename )
%
%

file = fullfile(path, [filename '.h5']);
lightField = h5read(file, '/LF');

lightField = permute(lightField, [5, 4, 3, 2, 1]);
lightField = double(lightField) / 255;

% Read attributes
focalLength = h5readatt(file, '/', 'focalLength');
% focalLength = focalLength * 1000; % to mm

% Diagonal field of view
fov = 2 * atan(1 / (2 * focalLength));
fov = fov .* [1, 1];

channels = h5readatt(file, '/', 'channels');

res = size(lightField);
dH = double(h5readatt(file, '/', 'dH'));
dV = double(h5readatt(file, '/', 'dV'));

% Distance between two cameras
cameraDist = [dV / res(1), dH / res(2)] * 1000;

% Distance between the planes
planeDist = double(h5readatt(file, '/', 'camDistance')) * 1000;

end

