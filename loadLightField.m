%% Load the light field from a folder of images

% path = 'lightFields/messerschmitt/7x7x384x512/';
% path = 'lightFields/dice/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';
% path = 'lightFields/dice_camera/dice_5x5_ap35/';
% path = 'lightFields/pink/';
path = 'lightFields/dice_camera/dice_parallel/3x3/';

[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [3, 3] );

lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

cameraPlaneDistance = 8;
distanceBetweenCameras = [0.3, 0.3];
fov = deg2rad([60, 45]);
distanceCameraPlaneToSensorPlane = computeSensorDistanceOfCamera(fov);

aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);
% fov = computeFOVForCamera(distanceCameraPlaneToSensorPlane, aspectRatio);

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
filename = 'siavash';

[ lightField, fov, distanceBetweenCameras] = loadLightFieldFromLytro( path, filename );

lightField = lightField(1 :2: 9, 1 :2: 9, :, :, :);
channels = 3;
lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
