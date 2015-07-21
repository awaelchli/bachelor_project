editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/legotruck/', 'png', [17, 17], 0.3);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 10;
attenuatorThickness = 1.5;
layerResolution = round( 1.3 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1.4, 1.4], attenuatorThickness, lightField.channels);
attenuator.placeLayer(1, -0.2);
attenuator.placeLayer(2, 0);
attenuator.placeLayer(3, 0.2);
attenuator.placeLayer(4, 0.4);
attenuator.placeLayer(5, 0.6);
attenuator.placeLayer(6, 0.8);
attenuator.placeLayer(7, 1.2);
attenuator.placeLayer(8, 1.4);
attenuator.placeLayer(9, 1.6);
attenuator.placeLayer(10, 1.7);

resamplingPlane = SensorPlane(round(1.3 * layerResolution), [1.4, 1.4], -attenuatorThickness / 2);
rec = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane);


%% Back projection P^T * LF

close all;
rec.evaluation.clearOutputFolder();
rec.constructPropagationMatrix();

P = rec.propagationMatrix.formSparseMatrix();
l = rec.resampledLightField.vectorizeData();
backProjection = P' * l;
b = backProjection ./ repmat(sum(P, 1)', [1, lightField.channels]);
b = permute(b, [2, 1]);
b = reshape(b, [attenuator.channels, attenuator.planeResolution, attenuator.numberOfLayers]);
b = permute(b, [4, 2, 3, 1]);

for i = 1 : attenuator.numberOfLayers
    figure('Name', sprintf('Layer %i', i));
    imshow(squeeze(b(i, :, :, :)), []);
    imwrite(squeeze(b(i, :, :, :)), sprintf('output/Back_Projection_Layer_%i.png', i));
end


%% Compute the layers

rec.computeAttenuationLayers();
rec.evaluation.displayLayers(1 : attenuator.numberOfLayers);

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(1 * layerResolution, [1, 1], 0);
rec2 = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
rec.reconstructLightField();

rec.evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6; 3, 7; 3, 8; 3, 9]);
% rec.evaluation.evaluateViews([9, 1; 9, 2; 9, 3; 9, 4; 9, 5; 9, 6; 9, 7; 9, 8; 9, 9]);
rec.evaluation.displayReconstructedViews();
% rec.evaluation.displayErrorImages();
rec.evaluation.storeReconstructedViews();
