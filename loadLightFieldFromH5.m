function [ lightField, channels, focalLength, fov, cameraDist, planeDist ] = loadLightFieldFromH5( path, filename )
% 
%

file = fullfile(path, [filename '.h5']);
lightField = h5read(file, '/LF');

lightField = permute(lightField, [5, 4, 3, 2, 1]);
lightField = double(lightField) / 255;

% Read attributes
focalLength = h5readatt(file, '/', 'focalLength');

% Diagonal field of view
fov_d = 2 * atan(1 / (2 * focalLength));

% aspect ratio r
r = size(lightField, 4) / size(lightField, 3);
fov_y = fov_d / sqrt((r^2 + 1));
fov_x = fov_y * r;

fov = [fov_x, fov_y];
% fov = fov .* [1, 1];

focalLength = focalLength * 1000; % to mm

channels = h5readatt(file, '/', 'channels');

res = size(lightField);
dH = double(h5readatt(file, '/', 'dH'));
dV = double(h5readatt(file, '/', 'dV'));

% Distance between two cameras
cameraDist = [dV / res(1), dH / res(2)] * 1000;

% Distance between the planes
planeDist = double(h5readatt(file, '/', 'camDistance')) * 1000;

end

