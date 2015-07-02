
editor = LightFieldEditor();
% editor.loadData('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
% editor.loadData('../lightFields/legotruck/', 'png', [17, 17], 0.3);
editor.loadData('../lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
editor.angularSliceY(1 : 2 : 17);
editor.angularSliceX(1 : 2 : 17);

%%

editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
% editor.distanceBetweenTwoCameras = [8, 8];
% editor.cameraPlaneZ = 500;
% editor.sensorSize = [150, 200];


lightField = editor.getLightField();
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
% Display reconstructions and error (true/false)
displayReconstruction = 1;
displayError = 0;
% Replication of the light field along given dimension (for visualization of 2D light fields)
replicationSizes = [1, 1, 1, 1, 1];
% reconstructLightField(rec.propagationMatrix.formSparseMatrix, rec.resampledLightField.lightFieldData, log(permute(attenuator.attenuationValues, [2, 3, 1, 4])), ...
%                       reconstructionIndices, replicationSizes, displayReconstruction, displayError, 'output/');

rec.reconstructLightField();
rec.displayReconstructedViews([1, 1; 2, 100]);





%% CSF LIGHT FIELD

editor = LightFieldEditor();
% editor.loadData('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
% editor.loadData('../lightFields/legotruck/', 'png', [17, 17], 0.3);
editor.loadData('../lightFields/CSF/', 'png', [9, 9], .8);

editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

%%
lightField = editor.getLightField();
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
% Display reconstructions and error (true/false)
% displayReconstruction = 1;
% displayError = 0;
% Replication of the light field along given dimension (for visualization of 2D light fields)
% replicationSizes = [1, 1, 1, 1, 1];
% reconstructLightField(rec.propagationMatrix.formSparseMatrix, rec.resampledLightField.lightFieldData, log(permute(attenuator.attenuationValues, [2, 3, 1, 4])), ...
%                       reconstructionIndices, replicationSizes, displayReconstruction, displayError, 'output/');

rec.reconstructLightField();
rec.displayReconstructedViews(reconstructionIndices);
