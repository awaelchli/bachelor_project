
editor = LightFieldEditor();
% editor.loadData('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
% editor.loadData('../lightFields/legotruck/legotruck_downsampled/', 'png', [9, 9], 1);
editor.loadData('../lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.3);
editor.angularSliceY(1 : 2 : 17);
editor.angularSliceX(1 : 2 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];

lightField = editor.getLightField();
attenuator = Attenuator(5, lightField.spatialResolution, lightField.sensorPlane.planeSize, .1, lightField.channels);

rec = Reconstruction(lightField, attenuator);
rec.computeLayers();

printLayers(permute(attenuator.attenuationValues(1 : 5, :, :, :), [2, 3, 1, 4]), [10, 10], 'output/', 'print1', 1);