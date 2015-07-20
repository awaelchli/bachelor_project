editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.4);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 10;
attenuatorThickness = 5;
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness / (numberOfLayers - 1), lightField.channels);

% Compute the propagation matrix for reconstruction: Here, the resampling plane is at the center of the attenuator
resamplingPlane = SensorPlane(1 * layerResolution, [1, 1], -attenuatorThickness / 2);
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
    h = figure('Name', sprintf('Layer %i', i));
    imshow(squeeze(b(i, :, :, :)), []);
    set(h, 'Position', get(0,'Screensize'))
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

rec.evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
rec.evaluation.displayReconstructedViews();
rec.evaluation.storeReconstructedViews();
