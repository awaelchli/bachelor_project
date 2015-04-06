%% Load the light field from a folder of images

% path = 'lightFields/messerschmitt/7x7x384x512/';
path = 'lightFields/dice/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';

[ lightField, channels ] = loadLightFieldFromFolder( path, 'png', [7, 7] );
fov = degtorad(10) .* [1, 1];

resolution = size(lightField);
resolution = resolution(1 : 4);

%% Load the light field from a H5 file

path = 'lightFields/rx_watch/';
filename = 'rx_watch';

[ lightField, channels, focalLength, fov, cameraDist ] = loadLightFieldFromH5( path, filename );

resolution = size(lightField);
resolution = resolution(1 : 4);


%% Load the light field from a Lytro image

path = 'lightFields/';
filename = 'coke';

[ lightField, fov, cameraDist] = loadLightFieldFromLytro( path, filename );

channels = 3;
resolution = size(lightField);
resolution = resolution(1 : 4);
