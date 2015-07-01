% Note: This script is only intended to load a light field from
% ORTHOGRAPHIC projections with ROTATED cameras. Here, FOV is the field of
% view of the light field, and not from the cameras.

%% Load the light field from a folder of images

% path = 'lightFields/messerschmitt/7x7x384x512/';
% path = '../lightFields/dice/';
path = '../lightFields/siaMask2/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';

[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [9, 9], 1);

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

fov = deg2rad([60, 60]);