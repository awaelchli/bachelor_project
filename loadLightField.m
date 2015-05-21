% This script is used to load different types of light fields. Each
% section can be run independently from the others and will load a
% different scene, with different parameters.
% 
% NOTES: 
%  
% The parameters z = "cameraPlaneDistance", ds = "distanceCameraPlaneToSensorPlane" 
% and dc = "distanceBetweenCameras" are related to disparity by 
%
%                       disparity = dc * ds / z.
%
% Use this equation to compute the missing parameter(s), depending on the
% ones that are known.

%% Template for loading a light field from a folder of images

% path = 'lightFields/messerschmitt/7x7x384x512/';
% path = 'lightFields/dice/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';
% path = 'lightFields/dice_camera/dice_5x5_ap35/';
% path = 'lightFields/pink/';
% path = '../lightFields/dice_camera/dice_parallel/3x3/';
% path = 'lightFields/dice_camera/dice_parallel/5x5-.05/';
path = 'lightFields/legotruck_downsampled_cropped_small/';

[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [17, 17] );

lightField = lightField(17:-2:1, 1:2:17, :, :, :);
% lightField = downsampleLighField(lightField, 0.2);

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

cameraPlaneDistance = 1;
distanceBetweenCameras = [4 * 2, 4 * 2]; 
fov = deg2rad([60, 45]);
distanceCameraPlaneToSensorPlane = cameraPlaneDistance * 22 / 8;
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);


%% Perspective lego truck scene

path = 'lightFields/legotruck_downsampled_cropped/';
[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [17, 17] );

lightField = lightField(17:-2:1, 1:2:17, :, :, :);
% lightField = downsampleLighField(lightField, 0.2);

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

cameraPlaneDistance = 500;
distanceBetweenCameras = [4 * 2, 4 * 2]; 
% fov = deg2rad([60, 45]);
distanceCameraPlaneToSensorPlane = 1;
% distanceCameraPlaneToSensorPlane = cameraPlaneDistance * 22 / 8;
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);
fov = computeFOVForCamera(distanceCameraPlaneToSensorPlane, aspectRatio);


%% Perspective Dice Scene

path = 'lightFields/dice_camera/dice_parallel/5x5-.05/';
[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [5, 5] );

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
 
cameraPlaneDistance = 8;
distanceBetweenCameras = [.05, .05]; 
fov = deg2rad([60, 45]);
distanceCameraPlaneToSensorPlane = 1;
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);

%% Orthographic Dice Scene

% path = 'lightFields/dice_camera/dice_parallel/orthographic/5x5.5/';
path = '../lightFields/dice_camera/dice_parallel/orthographic/';


[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [5, 5] );

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
 
fov = deg2rad([10, 10]);
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);

%% Load the light field from a H5 file

path = 'lightFields/rx_watch/';
filename = 'rx_watch';

[ lightField, channels, focalLength, fov, distanceBetweenCameras, cameraPlaneDistance ] = loadLightFieldFromH5( path, filename );

% Select smaller slice of light field
lightField = lightField(1 : 4, 1 : 4, :, :, :);

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

% lightFieldOP = convertLF( lightField, planeDist, fov, [9, 9], [300, 300]);


%% Load the light field from a Lytro image

path = 'lightFields/';
filename = 'pensAndSpeaker';

[ lightField, fov, distanceBetweenCameras] = loadLightFieldFromLytro( path, filename );

lightField = lightField(1:2:9, 1:2:9, :, :, :);
channels = 3;
lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

cameraPlaneDistance = 170;
distanceBetweenCameras = [5, 5] / 4;
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);
distanceCameraPlaneToSensorPlane = computeSensorDistanceOfCamera(fov);
% fov = 2 * atan(.5/400) + [0, 0];
