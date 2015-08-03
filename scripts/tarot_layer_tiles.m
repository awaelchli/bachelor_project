% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 15.2;

attenuatorSize = [actualLayerHeight, actualLayerWidth];
samplingPlaneSize = attenuatorSize;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
editor.angularSliceY(17 : -3 : 1);
editor.angularSliceX(17 : -3 : 1);
editor.distanceBetweenTwoCameras = [5.76, 5.76];
editor.cameraPlaneZ = 80;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = -0.5;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 5;
attenuatorThickness = actualThickness;
layerResolution = round( 1.1 * lightField.spatialResolution );

attenuator = Attenuator(numberOfLayers, layerResolution, attenuatorSize, attenuatorThickness, lightField.channels);

%% Compute tile positions

pixelSize = attenuatorSize ./ layerResolution;

tileResolution = [100, 100];
tileOverlap = [10, 10];
tileSize = tileResolution .* pixelSize;
tileOverlapSize = tileOverlap .* pixelSize;
numberOfTiles = ceil(attenuatorSize ./ (tileSize - tileOverlapSize));

tileStepSize = tileSize - tileOverlapSize;
[tileCentersY, tileCentersX] = computeCenteredGridPositions(numberOfTiles, tileStepSize);

totalTilingResolution = numberOfTiles .* tileResolution - (numberOfTiles - 1) .* tileOverlap;

%% Solve for each tile

for tileY = 1 : numberOfTiles(1)
    for tileX = 1 : numberOfTiles(2)
        
        
        fprintf('\nWorking on tile (%i, %i)...\n', tileY, tileX);
        
        tileCenter = [tileCentersY(tileY, tileX), tileCentersX(tileY, tileX)];
        attenuatorTile = Attenuator(numberOfLayers, tileResolution, tileSize, attenuatorThickness, lightField.channels);
        attenuatorTile.translate(tileCenter);
        
        tileSamplingPlane = SensorPlane(round(2 * tileResolution), tileSize, attenuatorTile.layerPositionZ(1));
        tileSamplingPlane.translate(tileCenter);
        rec = FastReconstructionForResampledLF(lightField, attenuatorTile, tileSamplingPlane);
        rec.verbose = 0;
        rec.computeAttenuationLayers();
        
        % Store the tiles
        out = sprintf('output/tile_%i_%i/', tileY, tileX);
        mkdir(out);
        rec.evaluation.outputFolder = out;
        rec.evaluation.storeLayers(1 : attenuator.numberOfLayers);
        
    end
end


%% Re-assemble the tiles

% TODO

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
