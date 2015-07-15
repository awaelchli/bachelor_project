editor = LightFieldEditor();
editor.inputFromImageCollection('../lightFields/dice/orthographic/7x7x384x512_fov10/', 'png', [7, 7], 1);
editor.lightFieldFOV = [10, 10];
lightField = editor.getOrthographicLightField();

attenuator = Attenuator(5, lightField.spatialResolution, [1, 1], 0.1, lightField.channels);

rec = ReconstructionForOrthographicLF(lightField, attenuator);
% rec.solver = @linearLeastSquares;
rec.computeAttenuationLayers();

close all;
rec.evaluation.displayLayers(1 : 5);
rec.reconstructLightField();

rec.evaluation.evaluateViews([4, 1; 4, 2; 4, 3; 4, 4; 4, 5; 4, 6; 4, 7]);
rec.evaluation.displayReconstructedViews();
rec.evaluation.displayErrorImages();
rec.evaluation.storeReconstructedViews();