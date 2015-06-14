% This script is used to decode light field data from different formats to a
% common format expected by the reconstruction pipeline. It stores additional 
% light field parameters and default reconstruction parameters.

%% Light field from a folder of rectified images

inputPath = 'lightFields/dice_camera/dice_parallel/3x3-.2_rect/';
outputPath = inputPath;

[ lightField, channels ] = loadLightFieldFromFolder(inputPath, 'png', [3, 3]);

% Light field parameters
lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
cameraPlaneDistance = 8;
distanceBetweenCameras = [.2, .2]; 
aspectRatio = lightFieldResolution(4) / lightFieldResolution(3);

% Default reconstruction parameters
NumberOfLayers = 5;
distanceBetweenLayers = 1;
layerResolution = lightFieldResolution([3, 4]);
layerHeight = 4;
layerWidth = layerHeight * aspectRatio;
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