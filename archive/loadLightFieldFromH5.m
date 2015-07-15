function [ lightField, channels, focalLength, fov, cameraDist, planeDist ] = loadLightFieldFromH5( path, filename )
%   
%   Input:      
%               path:           path to the H5 file
%               filename:       name of the H5 file
%   Output:
%               lightField:     the light field loaded from the H5 file
%               channels:       the number of color channels
%               focalLength:    the focal length of the cameras in mm
%               fov:            horizontal and vertical field of view of
%                               the cameras [fov_x, fov_y] in radians
%               cameraDist:     the distance between two cameras on the
%                               camera grid in X- and Y-direction stored as
%                               [camDist_x, camDist_y]
%               planeDist:      the distance between the camera grid and
%                               the scene origin

file = fullfile(path, [filename '.h5']);
lightField = h5read(file, '/LF');

lightField = permute(lightField, [5, 4, 3, 2, 1]);
lightField = double(lightField) / 255;

% Assume focal length is stored in meters
focalLength = h5readatt(file, '/', 'focalLength');

% Diagonal field of view in radians
fov_d = 2 * atan(1 / (2 * focalLength));

% aspect ratio r
r = size(lightField, 4) / size(lightField, 3);
fov_y = fov_d / sqrt((r^2 + 1));
fov_x = fov_y * r;

fov = [fov_x, fov_y];

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

