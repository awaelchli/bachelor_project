% This script is used to decode light field data from different formats to a
% common format expected by the reconstruction pipeline. It stores additional 
% light field parameters and default reconstruction parameters.

%% Light field from a folder of rectified images

inputPath = '../lightFields/tarot/small_angular_extent/';
outputPath = [inputPath 'downsampled-5x5-.3/'];

[ lightField, channels ] = loadLightFieldFromFolder(inputPath, 'png', [17, 17], 0.3);

lightField = lightField(1:2:17, 17:-2:1, :, :, :);
lightField = lightField(1:2:9, 1:2:9, :, :, :);

% Light field parameters
lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
cameraPlaneDistance = 200;
distanceBetweenCameras = [1.33, 1.33]; 
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);

% Default reconstruction parameters
NumberOfLayers = 5;
distanceBetweenLayers = 10;
layerResolution = lightFieldResolution([3, 4]);
layerHeight = 50;
layerWidth = 50;
layerSize = [layerHeight, layerWidth];

save([outputPath, 'lightField.mat'], 'lightField', ...
                                     'channels', ...
                                     'lightFieldResolution', ...
                                     'cameraPlaneDistance', ...
                                     'distanceBetweenCameras', ...
                                     'aspectRatio', ...
                                     'NumberOfLayers', ...
                                     'distanceBetweenLayers', ...
                                     'layerResolution', ...
                                     'layerSize');

%% Light field from .H5 file


%% Light field from Lytro