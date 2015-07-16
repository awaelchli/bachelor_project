
editor = LightFieldEditor();
% editor.inputFromImageCollection('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
editor.inputFromImageCollection('../lightFields/legotruck/', 'png', [17, 17], 0.3);
% editor.inputFromImageCollection('../lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
editor.angularSliceY(1 : 2 : 17);
editor.angularSliceX(1 : 2 : 17);
% editor.angularSliceY(1 : 9);
% editor.angularSliceX(1 : 9);
% editor.spatialSliceY(100);
% editor.angularSliceY(5);
% editor.channelSlice(1);

editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
% editor.distanceBetweenTwoCameras = [8, 8];
% editor.cameraPlaneZ = 500;
% editor.sensorSize = [150, 200];

lightFieldBlurred = editor.getPerspectiveLightField();

%%

numberOfLayers = 3;
attenuatorThickness = 1;
layerResolution = round( 1 * lightFieldBlurred.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, lightFieldBlurred.sensorPlane.planeSize, attenuatorThickness / (numberOfLayers - 1), lightFieldBlurred.channels);

rec = ReconstructionForResampledLF_V2(lightFieldBlurred, attenuator);
rec.computeAttenuationLayers();


close all;

% rec.evaluation.replicateSpatialDimensionY(10);
rec.evaluation.displayLayers(1 : numberOfLayers);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
rec.evaluation.clearOutputFolder();
% rec.evaluation.replicateSpatialDimensionY(10);
rec.evaluation.evaluateViews(reconstructionIndices);
rec.evaluation.displayReconstructedViews();
rec.evaluation.displayErrorImages();

%% CSF LIGHT FIELD

editor = LightFieldEditor();
% editor.inputFromImageCollection('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
% editor.inputFromImageCollection('../lightFields/legotruck/', 'png', [17, 17], 0.3);
editor.inputFromImageCollection('../lightFields/CSF/', 'png', [9, 9], 0.8);

editor.distanceBetweenTwoCameras = [0.1, 0.1];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

lightFieldBlurred = editor.getPerspectiveLightField();

%%
numberOfLayers = 3;
attenuatorThickness = numberOfLayers-1; % spacing is one
layerResolution = round( 1 * lightFieldBlurred.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, lightFieldBlurred.sensorPlane.planeSize, attenuatorThickness / (numberOfLayers - 1), lightFieldBlurred.channels);

rec = ReconstructionForResampledLF(lightFieldBlurred, attenuator);
rec.computeAttenuationLayers();


close all;
rec.evaluation.displayLayers(1 : numberOfLayers);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
rec.evaluation.clearOutputFolder();
rec.evaluation.evaluateViews(reconstructionIndices);
rec.evaluation.displayReconstructedViews();
rec.evaluation.storeReconstructedViews();
rec.evaluation.displayErrorImages();
rec.evaluation.storeErrorImages();









%% New version: sampling plane
% CSF light field

editor = LightFieldEditor();
editor.inputFromImageCollection('../lightFields/CSF/', 'png', [9, 9], 0.4);
editor.distanceBetweenTwoCameras = [0.1, 0.1];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;
editor.replicateChannelDimension(1);

editor.angularSliceY(1 : 2 : 9);
editor.angularSliceX(1 : 2 : 9);

% 2D 
% editor.angularSliceY(5);
% editor.spatialSliceY(100);

lightFieldBlurred = editor.getPerspectiveLightField();

%%
numberOfLayers = 3;
attenuatorThickness = numberOfLayers-1; % spacing is one
layerResolution = round( 1 * lightFieldBlurred.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness / (numberOfLayers - 1), lightFieldBlurred.channels);

resamplingPlane = SensorPlane(4 * layerResolution, [1, 1], editor.sensorPlaneZ);

rec = ReconstructionForResampledLF(lightFieldBlurred, attenuator, resamplingPlane);
rec.computeAttenuationLayers();


close all;
rec.evaluation.displayLayers(1 : numberOfLayers);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
rec.evaluation.clearOutputFolder();
rec.evaluation.evaluateViews(reconstructionIndices);
rec.evaluation.displayReconstructedViews();
% rec.evaluation.storeReconstructedViews();
rec.evaluation.displayErrorImages();
% rec.evaluation.storeErrorImages();
