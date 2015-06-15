% This script is used to decode light field data from different formats to a
% common format expected by the reconstruction pipeline. It stores additional 
% light field parameters and default reconstruction parameters.

%% Light field from a folder of rectified images

inputPath = '../lightFields/dice/perspective/wetzstein/dice_5x5_ap50/';
outputPath = inputPath;

[ lightField, channels ] = loadLightFieldFromFolder(inputPath, 'png', [5, 5]);

% Light field parameters
lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
cameraPlaneDistance = 127;
distanceBetweenCameras = [1.25, 1.25]; 
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);

% Default reconstruction parameters
NumberOfLayers = 5;
distanceBetweenLayers = 10;
layerResolution = lightFieldResolution([3, 4]);
layerHeight = 40;
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