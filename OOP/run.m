
editor = LightFieldEditor();
% editor.inputFromImageCollection('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
editor.inputFromImageCollection('../lightFields/legotruck/', 'png', [17, 17], 0.3);
% editor.inputFromImageCollection('../lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
% editor.angularSliceY(1 : 2 : 17);
% editor.angularSliceX(1 : 2 : 17);
editor.angularSliceY(1 : 9);
editor.angularSliceX(1 : 9);

editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
% editor.distanceBetweenTwoCameras = [8, 8];
% editor.cameraPlaneZ = 500;
% editor.sensorSize = [150, 200];

lightField = editor.getPerspectiveLightField();

%%

numberOfLayers = 3;
attenuatorThickness = 1;
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, lightField.sensorPlane.planeSize, attenuatorThickness / (numberOfLayers - 1), lightField.channels);

rec = ReconstructionForResampledLF(lightField, attenuator);
rec.computeAttenuationLayers();


close all;
printLayers(permute(attenuator.attenuationValues, [2, 3, 1, 4]), [10, 10], 'output/', 'print1', 1);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
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

lightField = editor.getPerspectiveLightField();

%%
numberOfLayers = 3;
attenuatorThickness = numberOfLayers-1; % spacing is one
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, lightField.sensorPlane.planeSize, attenuatorThickness / (numberOfLayers - 1), lightField.channels);

rec = ReconstructionForResampledLF(lightField, attenuator);
rec.computeAttenuationLayers();


close all;
printLayers(permute(attenuator.attenuationValues, [2, 3, 1, 4]), [10, 10], 'output/', 'print1', 1);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
rec.evaluation.evaluateViews(reconstructionIndices);
rec.evaluation.displayReconstructedViews();
rec.evaluation.storeReconstructedViews('output/');
rec.evaluation.displayErrorImages();
rec.evaluation.storeErrorImages('output/');









%% New version: sampling plane

editor = LightFieldEditor();
editor.inputFromImageCollection('../lightFields/CSF/', 'png', [9, 9], 0.1);
editor.distanceBetweenTwoCameras = [0.1, 0.1];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();

%%
numberOfLayers = 3;
attenuatorThickness = numberOfLayers-1; % spacing is one
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1.2, 1.2], attenuatorThickness / (numberOfLayers - 1), lightField.channels);

resamplingPlane = SensorPlane(layerResolution, [1.1, 1.1], 0);

rec = ReconstructionForResampledLF_V2(lightField, attenuator, resamplingPlane);
rec.computeAttenuationLayers();


close all;
% printLayers(permute(attenuator.attenuationValues, [2, 3, 1, 4]), [10, 10], 'output/', 'print1', 1);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
rec.evaluation.evaluateViews(reconstructionIndices);
rec.evaluation.displayReconstructedViews();
% rec.evaluation.storeReconstructedViews('output/');
% rec.evaluation.displayErrorImages();
% rec.evaluation.storeErrorImages('output/');

