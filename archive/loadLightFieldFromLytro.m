function [ lightField, fov, cameraDist ] = loadLightFieldFromLytro( path, filename )


file = fullfile(path, [filename '.lfr']);

% Decode the light field
% lytroPath = 'C:/Users/Adrian/AppData/Local/Lytro/cameras/';
lytroPath = 'C:/Users/waelchli/AppData/Local/Lytro/cameras/';
whiteImageDatabasePath = fullfile(lytroPath, 'WhiteImageDatabase.mat');

LFUtilUnpackLytroArchive(lytroPath);
LFUtilProcessWhiteImages(lytroPath);
DecodeOptions = LFDefaultField('DecodeOptions', 'WhiteImageDatabasePath', whiteImageDatabasePath);
[lightField, metadata, ~] = LFLytroDecodeImage(file, DecodeOptions);
lightField = lightField(:, :, :, :, 1 : 3);
lightField = double(lightField);

% Read light field metadata
sensorSize = [6.5, 4.5];
fL = metadata.devices.lens.focalLength * 1000;
fN = metadata.devices.lens.fNumber;
diam = fL / fN;                  % Diameter of the main lens in mm

% Horizontal and vertical field of view
hfov = 2 * atan(sensorSize(1) / (2 * fL));
vfov = 2 * atan(sensorSize(2) / (2 * fL));

fov = [vfov, hfov];

viewsY = size(lightField, 1);
viewsX = size(lightField, 2);

cameraDist = [diam / (viewsY - 1), diam / (viewsX - 1)];

end

