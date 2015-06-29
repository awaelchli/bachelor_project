
editor = LightFieldEditor();
% editor.loadData('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
editor.loadData('../lightFields/legotruck/legotruck_downsampled/', 'png', [9, 9], 1);
editor.distanceBetweenTwoCameras = [8, 8];
editor.cameraPlaneZ = 500;
editor.sensorSize = [150, 200];

lightField = editor.getLightField();
attenuator = Attenuator(5, lightField.spatialResolution, lightField.sensorPlane.planeSize, 10, lightField.channels);

rec = Reconstruction(lightField, attenuator);
rec.computeLayers();

printLayers(permute(attenuator.attenuationValues(1 : 5, :, :, :), [2, 3, 1, 4]), [10, 10], 'output/', 'print1', 1);