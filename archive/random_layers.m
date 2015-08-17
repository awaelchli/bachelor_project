%% construct fixed layers
clear all;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.3);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 1.6;

lightField = editor.getPerspectiveLightField();

mask = rand(1, 1, size(lightField.lightFieldData, 3), size(lightField.lightFieldData, 4), size(lightField.lightFieldData, 5));
lightField = LightFieldP(repmat(mask, [size(lightField.lightFieldData, 1), size(lightField.lightFieldData, 2), 1, 1, 1]), lightField.cameraPlane, lightField.sensorPlane);

numberOfLayers = 2;
attenuatorThickness = 3.2;
layerResolution = round( 1.0 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness, lightField.channels);

% attenuator.placeLayer(1, -3.2);
attenuator.placeLayer(1, -.8);
attenuator.placeLayer(2, .8);
% attenuator.placeLayer(5, 3.2);


resamplingPlane = SensorPlane(round(1 * layerResolution), [1, 1], attenuator.layerPositionZ(1));
rec = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
rec.constructPropagationMatrix();


P = rec.propagationMatrix.formSparseMatrix();

lightFieldVector = rec.resampledLightField.vectorizeData();

% Convert to log light field
lightFieldVector(lightFieldVector < Attenuator.minimumTransmission) = Attenuator.minimumTransmission;
lightFieldVectorLogDomain = log(lightFieldVector);

% Optimization constraints
ub = zeros(size(P, 2), rec.resampledLightField.channels); 
lb = zeros(size(ub)) + log(Attenuator.minimumTransmission);
x0 = zeros(size(ub));

% Solve the optimization problem using the provided solver
attenuationValuesLogDomain = sart(P, lightFieldVectorLogDomain, x0, lb, ub, 20);

% Attenuation values for FIRST LAYER!
randomLayers = exp(attenuationValuesLogDomain);

randomLayers = permute(randomLayers, [2, 1]);
randomLayers = reshape(randomLayers, [attenuator.channels, attenuator.planeResolution, 2]);
randomLayers = permute(randomLayers, [4, 2, 3, 1]);

save('randomLayers.mat', 'randomLayers');

%%
clear all;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.3);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 3;
attenuatorThickness = 3.2;
layerResolution = round( 1.0 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness, lightField.channels);

% attenuator.placeLayer(1, -3.2);
attenuator.placeLayer(1, -1.6);
attenuator.placeLayer(2, 0);
attenuator.placeLayer(3, 1.6);
% attenuator.placeLayer(5, 3.2);

load('randomLayers.mat');
attenuator.attenuationValues(1 : numberOfLayers - 1, :, :, :) = randomLayers;


resamplingPlane = SensorPlane(round(1 * layerResolution), [1, 1], attenuator.layerPositionZ(1));
rec = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
rec.constructPropagationMatrix();


firstLayerIndexRange = prod(attenuator.planeResolution);

P = rec.propagationMatrix.formSparseMatrix();
P1 = P(:, 1:firstLayerIndexRange);
P2 = P(:, firstLayerIndexRange+1:end);

%%
brightnessScale = 1.0;
lightFieldVector = rec.resampledLightField.vectorizeData();

% Convert to log light field
lightFieldVector(lightFieldVector < Attenuator.minimumTransmission) = Attenuator.minimumTransmission;
lightFieldVectorLogDomain = log(lightFieldVector*brightnessScale);

randomLayersVec = permute(randomLayers, [2, 3, 1, 4]);
randomLayersVec = reshape(randomLayersVec, size(P2, 2), []);

lightFieldVectorLogDomain = lightFieldVectorLogDomain - P2 * log(randomLayersVec);

% Optimization constraints
ub = zeros(size(P1, 2), rec.resampledLightField.channels); 
lb = zeros(size(ub)) + log(Attenuator.minimumTransmission);
x0 = zeros(size(ub));

% Solve the optimization problem using the provided solver
attenuationValuesLogDomain = sart(P1, lightFieldVectorLogDomain, x0, lb, ub, 20);

% Attenuation values for FIRST LAYER!
attenuationValues = exp(attenuationValuesLogDomain);

attenuationValues = permute(attenuationValues, [2, 1]);
attenuationValues = reshape(attenuationValues, [attenuator.channels, attenuator.planeResolution, 1]);
attenuationValues = permute(attenuationValues, [4, 2, 3, 1]);

attenuator.attenuationValues = [randomLayers; attenuationValues];

%%
layers = permute(attenuator.attenuationValues, [2, 3, 1, 4]);
layers = reshape(layers, size(P, 2), []);
reconstructionVector = P * log(layers);

% convert the light field vector to the 4D light field
reconstructionData = reshape(reconstructionVector, [rec.resampledLightField.resolution, rec.resampledLightField.channels]);
reconstructionData = exp(reconstructionData);% / brightnessScale;
reconstructedLF = LightField(reconstructionData);
evaluation = ReconstructionEvaluation(rec.resampledLightField, attenuator, reconstructedLF);

%%

rec.evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
rec.evaluation.displayReconstructedViews();
% rec.evaluation.displayErrorImages();
rec.evaluation.storeReconstructedViews();
