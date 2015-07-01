
editor = LightFieldEditor();
% editor.loadData('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
editor.loadData('../lightFields/legotruck/legotruck_downsampled/', 'png', [9, 9], 1);
% editor.loadData('../lightFields/tarot/large_angular_extent/', 'png', [17, 17], 0.3);
% editor.angularSliceY(1 : 2 : 17);
% editor.angularSliceX(1 : 2 : 17);
% editor.distanceBetweenTwoCameras = [0.03, 0.03];
% editor.cameraPlaneZ = 10;
% editor.sensorSize = [1, 1];
editor.distanceBetweenTwoCameras = [8, 8];
editor.cameraPlaneZ = 500;
editor.sensorSize = [150, 200];

lightField = editor.getLightField();
attenuator = Attenuator(5, lightField.spatialResolution, lightField.sensorPlane.planeSize, 10, lightField.channels);

rec = Reconstruction(lightField, attenuator);
rec.computeLayers();

printLayers(permute(attenuator.attenuationValues(1 : 5, :, :, :), [2, 3, 1, 4]), [10, 10], 'output/', 'print1', 1);

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6; 7, 7; 8, 8; 9, 9];
% Display reconstructions and error (true/false)
displayReconstruction = 1;
displayError = 0;
% Replication of the light field along given dimension (for visualization of 2D light fields)
replicationSizes = [1, 1, 1, 1, 1];
reconstructLightField(rec.propagationMatrix.formSparseMatrix, rec.resampledLightField.lightFieldData, log(permute(attenuator.attenuationValues(1 : 5, :, :, :), [2, 3, 1, 4])), ...
                      reconstructionIndices, replicationSizes, displayReconstruction, displayError, 'output/');