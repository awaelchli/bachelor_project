
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

rec = ReconstructionForResampledLF(lightFieldBlurred, attenuator);
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

rec = ReconstructionForResampledLF_V2(lightFieldBlurred, attenuator, resamplingPlane);
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



%% Legotruck with SAMPLING PLANE

editor = LightFieldEditor();
% editor.inputFromImageCollection('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
editor.inputFromImageCollection('../lightFields/legotruck/', 'png', [17, 17], 0.2);
% editor.inputFromImageCollection('../lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
% editor.angularSliceY(1 : 9);
% editor.angularSliceX(1 : 9);
% editor.channelSlice(1);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;
% editor.distanceBetweenTwoCameras = [8, 8];
% editor.cameraPlaneZ = 500;
% editor.sensorSize = [150, 200];

lightField = editor.getPerspectiveLightField();
%%
% Spatial blur
blurred = zeros(size(lightField.lightFieldData));
for i = 1 : lightField.angularResolution(1)
    for j = 1 : lightField.angularResolution(2)
        blurred(i, j, :, :, :) = imgaussfilt(squeeze(lightField.lightFieldData(i, j, :, :, :)), 2);
    end
end

% blurred = arrayfun(@(i, j) imgaussfilt(squeeze(lightField.lightFieldData(i, j, :, :, :))), 1 : lightField.angularResolution(1), 1 : lightField.angularResolution(2));
size(blurred)
lightFieldBlurred = LightFieldP(blurred, lightField.cameraPlane, lightField.sensorPlane);

%%

numberOfLayers = 5;
attenuatorThickness = 5;
layerResolution = round( 1 * lightFieldBlurred.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness / (numberOfLayers - 1), lightFieldBlurred.channels);


resamplingPlane = SensorPlane(2 * layerResolution, [1, 1], 0);

rec = ReconstructionForResampledLF_V2(lightFieldBlurred, attenuator, resamplingPlane);
rec.computeAttenuationLayers();

resamplingPlane = SensorPlane(1 * layerResolution, [1, 1], 0);
rec2 = ReconstructionForResampledLF_V2(lightFieldBlurred, attenuator, resamplingPlane);
rec2.computeAttenuationLayers();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
close all;

rec.evaluation.displayLayers(1 : numberOfLayers);
rec.evaluation.storeLayers(1 : numberOfLayers);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();
rec.evaluation.clearOutputFolder();
rec.evaluation.evaluateViews(reconstructionIndices);
rec.evaluation.displayReconstructedViews();
rec.evaluation.storeReconstructedViews();
rec.evaluation.displayErrorImages();
rec.evaluation.storeErrorImages();


%% Back projection P^T * LF
P = rec.propagationMatrix.formSparseMatrix();
l = reshape(rec.reconstructedLightField.lightFieldData, [], lightFieldBlurred.channels);
backProjection = P' * l;
b = backProjection ./ max(backProjection(:));
b = permute(b, [2, 1]);
b = reshape(b, [attenuator.channels, attenuator.planeResolution, attenuator.numberOfLayers]);
b = permute(b, [4, 2, 3, 1]);
% b = exp(b);
figure; imshow(squeeze(b(1, :, :, :)));
figure; imshow(squeeze(b(2, :, :, :)));
figure; imshow(squeeze(b(3, :, :, :)));
figure; imshow(squeeze(b(4, :, :, :)));
figure; imshow(squeeze(b(5, :, :, :)));

for i = 1 : attenuator.numberOfLayers
    imwrite(squeeze(b(i, :, :, :)), sprintf('output/back_projection_L%i.png', i));
end


