
editor = LightFieldEditor();
editor.loadData('../lightFields/dice/perspective/3x3-.2_rect/', 'png', [3, 3], 1);
editor.distanceBetweenTwoCameras = [0.2, 0.2];
editor.cameraPlaneZ = 8;
editor.sensorSize = [4, 4 * 1.3584];

lightField = editor.getLightField();
attenuator = Attenuator(5, lightField.spatialResolution, lightField.sensorPlane.planeSize, 1, lightField.channels);

rec = Reconstruction(lightField, attenuator);
rec.computeLayers();

printLayers(permute(attenuator.attenuationValues(1 : 3, :, :, :), [2, 3, 1, 4]), [10, 10], 'temp/', 'print1', 1);