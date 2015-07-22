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

numberOfLayers = 5;
attenuatorThickness = 5;
layerResolution = round( 1.0 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness, lightField.channels);

attenuator.placeLayer(1, -3.2);
attenuator.placeLayer(2, -1.6);
attenuator.placeLayer(3, 0);
attenuator.placeLayer(4, 1.6);
attenuator.placeLayer(5, 3.2);

load('randomLayers.mat');
attenuator.attenuationValues(1 : numberOfLayers - 1, :, :, :) = randomLayers;


resamplingPlane = SensorPlane(round(3 * layerResolution), [1, 1], attenuator.layerPositionZ(1));
rec = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
rec.computePropagationMatrix();


firstLayerIndexRange = prod(attenuator.planeResolution);

P = rec.propagationMatrix.formSparseMatrix();
P1 = P(:, 1:firstLayerIndexRange);
P2 = P(:, firstLayerIndexRange+1:end);




