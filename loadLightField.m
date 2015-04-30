%% Load the light field from a folder of images

% path = 'lightFields/messerschmitt/7x7x384x512/';
% path = 'lightFields/dice/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';
path = 'lightFields/dice_camera/dice_5x5_ap35/';

[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [5, 5] );

% The field of view of the lightfield (not the cameras), in X and in Y direction
fov = degtorad(10) .* [1, 1];

resolution = size(lightField);
resolution = resolution(1 : 4);

%% Load the light field from a H5 file

path = 'lightFields/fruits/';
filename = 'fruits';

[ lightField, channels, focalLength, fov, distanceBetweenCameras, cameraPlaneDistance ] = loadLightFieldFromH5( path, filename );

% Select smaller slice of light field
lightField = lightField(1 : 4, 1 : 4, :, :, :);

resolution = size(lightField);
resolution = resolution(1 : 4);

% lightFieldOP = convertLF( lightField, planeDist, fov, [9, 9], [300, 300]);


%% Load the light field from a Lytro image

path = '../lightFields/';
filename = 'coke';

[ lightField, fov, distanceBetweenCameras] = loadLightFieldFromLytro( path, filename );

channels = 3;
resolution = size(lightField);
resolution = resolution(1 : 4);
