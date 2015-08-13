% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 15.2;

attenuatorSize = [actualLayerHeight, actualLayerWidth];
samplingPlaneSize = attenuatorSize;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.5);
editor.angularSliceY(17 : -3 : 1);
editor.angularSliceX(17 : -3 : 1);
editor.distanceBetweenTwoCameras = [5.76, 5.76] * 6;
% editor.distanceBetweenTwoCameras = [1.8, 1.8] * 6;
editor.cameraPlaneZ = 80 * 6;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = -0.5;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 5;
attenuatorThickness = actualThickness;
layerResolution = round(1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, attenuatorSize, attenuatorThickness, lightField.channels);

resamplingPlane = SensorPlane(round(2 * layerResolution), samplingPlaneSize, attenuator.layerPositionZ(1));
rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane);


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

clear b backProjection;


%% Compute the layers

rec.computeAttenuationLayers();
rec.evaluation.displayLayers(1 : attenuator.numberOfLayers);
rec.evaluation.storeLayers(1 : attenuator.numberOfLayers);

rec.evaluation.printLayers([1, 2], 15);
rec.evaluation.printLayers([3, 4], 15);
rec.evaluation.printLayers(5, 15);

%% Reconstruct light field from layers

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(round(1.5 * layerResolution), samplingPlaneSize, lightField.sensorPlane.z);
rec2 = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
rec.reconstructLightField();

rec.evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
% rec.evaluation.evaluateViews([1, 3; 2, 3; 3, 3; 4, 3; 5, 3; 6, 3]);
rec.evaluation.displayReconstructedViews();
% rec.evaluation.displayErrorImages();
rec.evaluation.storeReconstructedViews();


%% Store all reconstructed views

indY = 1 : lightField.angularResolution(1);
indX = 1 : lightField.angularResolution(2);

indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));

indices = [indY(:), indX(:)];
rec.evaluation.evaluateViews(indices);
rec.evaluation.storeReconstructedViews();
