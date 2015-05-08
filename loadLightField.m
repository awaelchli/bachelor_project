%% Load the light field from a folder of images

% path = 'lightFields/messerschmitt/7x7x384x512/';
% path = 'lightFields/dice/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';
% path = 'lightFields/dice_camera/dice_5x5_ap35/';
% path = 'lightFields/pink/';
path = 'lightFields/dice_parallel2/';

[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [3, 3] );


% The field of view of the lightfield (not the cameras), in X and in Y direction
% fov = degtorad(10) .* [1, 1];
cameraPlaneDistance = 15+4.5;
distanceBetweenCameras = [.2, .2];
distanceCameraPlaneToSensorPlane = 5;

aspectRatio = lightFieldResolution(2) / lightFieldResolution(1);
fov = computeFOVForCamera(distanceCameraPlaneToSensorPlane, aspectRatio);

% lightField = lightField(1, 1:4:120, :, :, :);
lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);

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
