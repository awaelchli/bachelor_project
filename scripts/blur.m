editor = LightFieldEditor();
% editor.inputFromImageCollection('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
% editor.inputFromImageCollection('../lightFields/legotruck/', 'png', [17, 17], 0.2);
editor.inputFromImageCollection('../lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

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
attenuatorThickness = 4;
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness / (numberOfLayers - 1), lightFieldBlurred.channels);


resamplingPlane = SensorPlane(1 * layerResolution, [1, 1], - attenuatorThickness / 2);

rec = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
rec.solver = @linearLeastSquares;
rec.computeAttenuationLayers();


resamplingPlane2 = SensorPlane(1 * layerResolution, [1, 1], 0);
rec2 = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.computeAttenuationLayers();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
close all;

rec.evaluation.displayLayers(1 : numberOfLayers);
rec.evaluation.clearOutputFolder();
rec.evaluation.storeLayers(1 : numberOfLayers);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
rec.reconstructLightField();

rec.evaluation.evaluateViews(reconstructionIndices);
% rec.evaluation.displayReconstructedViews();
rec.evaluation.storeReconstructedViews();
% rec.evaluation.displayErrorImages();
rec.evaluation.storeErrorImages();
