function [ lightField, channels, focalLength, fov, cameraDist ] = loadLightFieldFromH5( path, filename )
%
%

file = fullfile(path, [filename '.h5']);
lightField = h5read(file, '/LF');

lightField = permute(lightField, [5, 4, 3, 2, 1]);
lightField = double(lightField) / 255;

% Read attributes
focalLength = h5readatt(file, '/', 'focalLength');
% focalLength = focalLength * 1000; % to mm

fov = 2 * atan(1 / (2 * focalLength));

channels = h5readatt(file, '/', 'channels');

cameraDist = h5readatt(file, '/', 'dH');
cameraDist = cameraDist * 1000;

% fov = degtorad(90);

end

