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
layerResolution = round( 1 * lightField.spatialResolution );

attenuator = Attenuator(numberOfLayers, layerResolution, attenuatorSize, attenuatorThickness, lightField.channels);

%% Compute tile positions

tileResolution = [100, 100];
% tileOverlap = [25, 25];
tileOverlap = ceil(0.25 * tileResolution);
tiledPlane = TiledPixelPlane(attenuator.planeResolution, attenuator.planeSize);
tiledPlane.regularTiling(tileResolution, tileOverlap);

%% Solve for each tile

tileSumMatrix = zeros(size(attenuator.attenuationValues));
weightSumMatrix = zeros(size(attenuator.attenuationValues));

tileIndexY = repmat(1 : tiledPlane.tilingResolution(1), [tiledPlane.tilingResolution(2), 1]);
tileIndexX = repmat(1 : tiledPlane.tilingResolution(2), [1, tiledPlane.tilingResolution(1)]);
tileIndices = [tileIndexY(:), tileIndexX(:)];

for index = 1 : size(tileIndices, 1)
        
        tileY = tileIndices(index, 1);
        tileX = tileIndices(index, 2);
        
        fprintf('\nWorking on tile %i/%i...\n', index, size(tileIndices, 1));
        
        tile = tiledPlane.tiles{tileY, tileX};
        attenuatorTile = Attenuator(numberOfLayers, tile.planeResolution, tile.planeSize, attenuatorThickness, lightField.channels);
        attenuatorTile.translate(tile.planeCenter);
        
        tileSamplingPlane = SensorPlane(ceil(1.2 * tile.planeResolution), 1.2 * tile.planeSize, attenuatorTile.layerPositionZ(1));
        tileSamplingPlane.translate(tile.planeCenter);
        rec = FastReconstructionForResampledLF(lightField, attenuatorTile, tileSamplingPlane);
        rec.verbose = 0;
        rec.computeAttenuationLayers();
        
        tileValues = attenuatorTile.attenuationValues;
        indicesY = tile.pixelIndexInParentY(:, 1);
        indicesX = tile.pixelIndexInParentX(1, :);
        
        range = 10;
        
        x1 = linspace(-range, range, tile.planeResolution(1)); 
        x2 = linspace(-range, range, tile.planeResolution(2));
        [X, Y] = meshgrid(x2, x1);
        
        tmp = ones(tile.planeResolution);
%         size(tmp)
        tmp = min(cumsum(tmp,1), cumsum(tmp,2));
        tmp = min(tmp, tmp(end:-1:1, end:-1:1));
        tmp = tmp.^2;
%         size(tmp)
        F = tmp;
%         F = 1 ./(X.^2 + Y.^2).^(1/5);
%         F = rand(size(X));
%         max(F(:))
%         min(F(:))
%         F(F > 100) = 100;
%         F = 1 - F/max(F(:));
        
%         F = ones(size(X));
        
%         F = F ./ tiledPlane.coverageMatrix(indicesY, indicesX);
%         figure; imshow(F);
        F = permute(repmat(F, [1, 1, attenuatorTile.channels, attenuatorTile.numberOfLayers]), [4, 1, 2, 3]);
        
        tileValues = F .* tileValues;
        tileSumMatrix(:, indicesY, indicesX, :) = tileSumMatrix(:, indicesY, indicesX, :) + tileValues;
        weightSumMatrix(:, indicesY, indicesX, :) = weightSumMatrix(:, indicesY, indicesX, :) + F;
        
%         figure; imshow(squeeze(tileValues(1, :, :, :)));
        
        % Store the tiles
        out = sprintf('output/tile_%i_%i/', tileY, tileX);
        mkdir(out);
        rec.evaluation.outputFolder = out;
        rec.evaluation.storeLayers(1 : attenuator.numberOfLayers);
end

% attenuationValues = tileSumMatrix ./ permute(repmat(tiledPlane.coverageMatrix, [1, 1, numberOfLayers, attenuator.channels]), [3, 1, 2, 4]);
attenuationValues = tileSumMatrix ./ weightSumMatrix;
W = weightSumMatrix ./ permute(repmat(tiledPlane.coverageMatrix, [1, 1, numberOfLayers, attenuator.channels]), [3, 1, 2, 4]);
figure; imshow(squeeze(W(1, :, :, 1)), []);
figure; imshow(squeeze(weightSumMatrix(1, :, :, 1)), []);
figure; imshow(tiledPlane.coverageMatrix, []);
attenuator.attenuationValues = attenuationValues;

%% Show the layers
% close all;
for n = 1 : numberOfLayers
    
    figure; 
    imshow(squeeze(attenuator.attenuationValues(n, :, :, :)));
    
end

%% Reconstruct light field from layers
close all;
% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(ceil(1 * layerResolution), samplingPlaneSize, lightField.sensorPlane.z);
rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec.propagationMatrix);
rec.reconstructLightField();

rec.evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
% rec.evaluation.evaluateViews([1, 3; 2, 3; 3, 3; 4, 3; 5, 3; 6, 3]);
rec.evaluation.displayReconstructedViews();
% rec.evaluation.displayErrorImages();
% rec2.evaluation.storeReconstructedViews();


%% Store evaluation data to output folder

indY = 1 : lightField.angularResolution(1);
indX = 1 : lightField.angularResolution(2);

indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));

indices = [indY(:), indX(:)];
rec.evaluation.evaluateViews(indices);
rec.evaluation.storeReconstructedViews();
rec.evaluation.storeErrorImages();
rec.evaluation.storeLayers(1 : numberOfLayers);
