function [ P, resampledLightField ] = computeMatrixPForResampledLF( NumberOfLayers, ...
                                                                    layerResolution, ...
                                                                    layerSize, ...
                                                                    distanceBetweenLayers, ...
                                                                    cameraPlaneDistance, ...
                                                                    distanceBetweenTwoCameras, ...
                                                                    weightFunctionHandle, ...
                                                                    boxRadius, ...
                                                                    sensorPlaneZ, ...
                                                                    lightField)
% Inputs:
%
%   NumberOfLayers:                 Number of layers in the attenuator
%   layerResolution:                Resolution of the layers [resY, resX]
%   layersSize:                     Size of the layer in mm [width, height]
%   distanceBetweenLayers:          Distance between the layers in mm
%   cameraPlaneDistance:            Distance between the camera plane and
%                                   the origin of the scene in mm
%   distanceBetweenTwoCameras:      distance between two cameras on the
%                                   camera plane in mm
%   weightFunctionHandle:           A function handle to compute the weights 
%                                   for the ray intersections with the pixels
%   boxRadius:                      Radius (in pixels) of the square box 
%                                   centered at each pixel 
%   lightField:                     The light field used in the resampling/interpolation process                                
%
% Output:
%
%   P:                              The propagation matrix, describing where each ray hits
%                                   each layer
%   resampledLightField:            The interpolated light field from the
%                                   intersections on the sensor plane


lightFieldResolution = size(lightField);
lightFieldResolution = lightFieldResolution(1 : 4);
channels = size(lightField, 5);
% boxSize = [2 * boxRadius + 1, 2 * boxRadius + 1];

% Is = cell(lightFieldResolution(1), lightFieldResolution(2), NumberOfLayers, boxSize(1), boxSize(2));
Is = cell(lightFieldResolution(1), lightFieldResolution(2), NumberOfLayers);
Js = cell(size(Is));
Ss = cell(size(Is));

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(lightFieldResolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ pixelPositionsOnFirstLayerMatrixY, pixelPositionsOnFirstLayerMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize);

[ pixelIndexOnFirstLayerMatrixY, pixelIndexOnFirstLayerMatrixX ] = ndgrid(1 : layerResolution(1), 1 : layerResolution(2));

layerPositionsZ = -(NumberOfLayers - 1) * distanceBetweenLayers / 2 : distanceBetweenLayers : (NumberOfLayers - 1) * distanceBetweenLayers / 2;
layerPositionsZ
% sensorPlaneZ = 0;

fprintf('Views done: \n');

resampledLFResolution = [ lightFieldResolution([1, 2]), layerResolution ];
resampledLightField = zeros([ resampledLFResolution, channels ]);

% Pre-compute the column indices for the first layer
% columnsForFirstLayer = computeColumnIndicesForP(pixelIndexOnFirstLayerMatrixY, ...
%                                                 pixelIndexOnFirstLayerMatrixX, ...
%                                                 1, ...
%                                                 NumberOfLayers, ...
%                                                 layerResolution);

for camIndexY = 1 : lightFieldResolution(1)
    for camIndexX = 1 : lightFieldResolution(2)
        
    
        % get the position of the current camera on the camera plane
        cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                           cameraPositionMatrixX(camIndexY, camIndexX) ];
        
        firstLayerZ = layerPositionsZ(1);
        
        [ positionsOnSensorPlaneMatrixY, ...
          positionsOnSensorPlaneMatrixX ] = computeRayIntersectionsOnPlane( cameraPosition, ...
                                                                            cameraPlaneDistance, ...
                                                                            firstLayerZ, ...
                                                                            sensorPlaneZ, ...
                                                                            pixelPositionsOnFirstLayerMatrixY, ...
                                                                            pixelPositionsOnFirstLayerMatrixX );
        
        [ ~, ~, ...
          sensorIntersectionMatrixY, ...
          sensorIntersectionMatrixX ] = computePixelIndicesOnPlane( positionsOnSensorPlaneMatrixY, ...
                                                                    positionsOnSensorPlaneMatrixX, ...
                                                                    lightFieldResolution([3, 4]), ...
                                                                    layerSize, ...
                                                                    @round );
        
        invalidRayIndicesForSensorY = sensorIntersectionMatrixY(:, 1) == 0;
        invalidRayIndicesForSensorX = sensorIntersectionMatrixX(1, :) == 0;

        pixelIndexOnSensorMatrixY = pixelIndexOnFirstLayerMatrixY;
        pixelIndexOnSensorMatrixX = pixelIndexOnFirstLayerMatrixX;
        
        pixelIndexOnSensorMatrixY(invalidRayIndicesForSensorY, :) = 0;
        pixelIndexOnSensorMatrixX(:, invalidRayIndicesForSensorX) = 0;
        
        % Interpolating the current view of the light field
        view = squeeze(lightField(camIndexY, camIndexX, :, :, :));
        gridVectors = {sensorIntersectionMatrixY(:, 1), sensorIntersectionMatrixX(1, :), 1 : channels};
        
        % Remove arrays of singleton dimensions (2D light fields or single
        % channel)
        indicesOfScalars = cellfun(@isscalar, gridVectors);
        grid = cell(1, nnz(~indicesOfScalars));
        [ grid{:} ] = ndgrid(gridVectors{~indicesOfScalars});
        
        resampledLightField(camIndexY, camIndexX, :, :, :) = interpn(view, grid{:});
        
        rowsForFirstLayer = computeRowIndicesForP(camIndexY, ...
                                                  camIndexX, ...
                                                  pixelIndexOnSensorMatrixY, ... 
                                                  pixelIndexOnSensorMatrixX, ...
                                                  resampledLFResolution);

        columnsForFirstLayer = computeColumnIndicesForP(pixelIndexOnSensorMatrixY, ...
                                                        pixelIndexOnSensorMatrixX, ...
                                                        1, ...
                                                        NumberOfLayers, ...
                                                        layerResolution);
                                                    
%                                                     size(rowsForFirstLayer) == size(columnsForFirstLayer)
                                 
        % Insert indices and values for the first layer
        Is{camIndexY, camIndexX, 1, 1, 1} = rowsForFirstLayer';
        Js{camIndexY, camIndexX, 1, 1, 1} = columnsForFirstLayer';
        Ss{camIndexY, camIndexX, 1, 1, 1} = ones(size(rowsForFirstLayer))';
        
%         for sy = -boxRadius : boxRadius
%             for sx = -boxRadius : boxRadius
        
                for layer = 2 : NumberOfLayers

                    % adjust distance for current layer; the coordinate origin is
                    % at the center of the layer stack
                    currentLayerZ = layerPositionsZ(layer);

                    [ positionsOnLayerMatrixY, ...
                      positionsOnLayerMatrixX ] = computeRayIntersectionsOnPlane( cameraPosition, ...
                                                                                  cameraPlaneDistance, ...
                                                                                  firstLayerZ, ...
                                                                                  currentLayerZ, ...
                                                                                  pixelPositionsOnFirstLayerMatrixY, ...
                                                                                  pixelPositionsOnFirstLayerMatrixX );



                    [ pixelIndexOnLayerMatrixY, ...
                      pixelIndexOnLayerMatrixX, ...
                      layerIntersectionMatrixY, ...
                      layerIntersectionMatrixX ] = computePixelIndicesOnPlane( positionsOnLayerMatrixY, ...
                                                                               positionsOnLayerMatrixX, ...
                                                                               layerResolution, ...
                                                                               layerSize, ...
                                                                               @round );
                                                                           
%                     tempPixelIndexOnLayerMatrixY = min(pixelIndexOnLayerMatrixY + sy, layerResolution(1));
%                     tempPixelIndexOnLayerMatrixY = max(tempPixelIndexOnLayerMatrixY, 0);
%                     tempPixelIndexOnLayerMatrixX = min(pixelIndexOnLayerMatrixX + sx, layerResolution(2));
%                     tempPixelIndexOnLayerMatrixX = max(tempPixelIndexOnLayerMatrixX, 0);

%                     weightsForLayerMatrix = computeRayIntersectionWeights( tempPixelIndexOnLayerMatrixY, ...
%                                                                            tempPixelIndexOnLayerMatrixX, ...
%                                                                            layerIntersectionMatrixY, ...
%                                                                            layerIntersectionMatrixX, ...
%                                                                            weightFunctionHandle );
% 
%                     tempPixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
%                     tempPixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;
                    
                    weightsForLayerMatrix = computeRayIntersectionWeights( pixelIndexOnLayerMatrixY, ...
                                                                           pixelIndexOnLayerMatrixX, ...
                                                                           layerIntersectionMatrixY, ...
                                                                           layerIntersectionMatrixX, ...
                                                                           weightFunctionHandle );

                    pixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
                    pixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;

%                     layerPixelIndicesY = tempPixelIndexOnLayerMatrixY(tempPixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
%                     layerPixelIndicesX = tempPixelIndexOnLayerMatrixX(1, tempPixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

                    layerPixelIndicesY = pixelIndexOnLayerMatrixY(pixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
                    layerPixelIndicesX = pixelIndexOnLayerMatrixX(1, pixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

                    layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
                    layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

                    layerIndices = layer + zeros(size(layerPixelIndicesY));

                    % convert the subscripts to column indices
                    columns = sub2ind([layerResolution NumberOfLayers], layerPixelIndicesY(:), ...
                                                                        layerPixelIndicesX(:), ...
                                                                        layerIndices(:));

%                     invalidRayIndicesForLayerY = tempPixelIndexOnLayerMatrixY(:, 1) == 0;
%                     invalidRayIndicesForLayerX = tempPixelIndexOnLayerMatrixX(1, :) == 0;

                    invalidRayIndicesForLayerY = pixelIndexOnLayerMatrixY(:, 1) == 0;
                    invalidRayIndicesForLayerX = pixelIndexOnLayerMatrixX(1, :) == 0;

%                     tempPixelIndexOnSensorMatrixY = pixelIndexOnSensorMatrixY;
%                     tempPixelIndexOnSensorMatrixX = pixelIndexOnSensorMatrixX;
% 
%                     tempPixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
%                     tempPixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;
% 
%                     rows = computeRowIndicesForP(camIndexY, ...
%                                                  camIndexX, ...
%                                                  tempPixelIndexOnSensorMatrixY, ... 
%                                                  tempPixelIndexOnSensorMatrixX, ...
%                                                  resampledLFResolution);

                    pixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
                    pixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;

                    rows = computeRowIndicesForP(camIndexY, ...
                                                 camIndexX, ...
                                                 pixelIndexOnSensorMatrixY, ... 
                                                 pixelIndexOnSensorMatrixX, ...
                                                 resampledLFResolution);

                    weights = weightsForLayerMatrix;
                    weights = weights(~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY), :);
                    weights = weights(: , ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX));
                    
%                     boxIndexY = sy + boxRadius + 1;
%                     boxIndexX = sx + boxRadius + 1;
                    
%                     Is{camIndexY, camIndexX, layer, boxIndexY, boxIndexX} = rows;
%                     Js{camIndexY, camIndexX, layer, boxIndexY, boxIndexX} = columns;
%                     Ss{camIndexY, camIndexX, layer, boxIndexY, boxIndexX} = weights(:);
%                     numel(rows) == numel(weights)
                    Is{camIndexY, camIndexX, layer} = rows';
                    Js{camIndexY, camIndexX, layer} = columns';
                    Ss{camIndexY, camIndexX, layer} = permute(weights(:), [2, 1]);
%                     Ss{camIndexY, camIndexX, layer} = rand(size(rows));
                end
%             end
%         end
        
        fprintf('(%i, %i) ', camIndexY, camIndexX);
    end
    fprintf('\n');
end
% 
% Is
% Js
% Ss

P = sparse([Is{:}], [Js{:}], [Ss{:}], prod(resampledLFResolution), prod([ NumberOfLayers layerResolution ]));

end


function [ rows ] = computeRowIndicesForP(camIndexY, ...
                                          camIndexX, ...
                                          pixelIndexMatrixY, ... 
                                          pixelIndexMatrixX, ...
                                          lightFieldResolution)

cameraPixelIndicesY = pixelIndexMatrixY(pixelIndexMatrixY(:, 1) ~= 0, 1); % column vector
cameraPixelIndicesX = pixelIndexMatrixX(1, pixelIndexMatrixX(1, :) ~= 0); % row vector

cameraPixelIndicesY = repmat(cameraPixelIndicesY, 1, numel(cameraPixelIndicesX)); 
cameraPixelIndicesX = repmat(cameraPixelIndicesX, size(cameraPixelIndicesY, 1), 1); 

% make copies of the image indices
imageIndicesY = camIndexY + zeros(size(cameraPixelIndicesY));
imageIndicesX = camIndexX + zeros(size(cameraPixelIndicesX));

% convert the 4D subscipts to row indices all at once
rows = sub2ind(lightFieldResolution, imageIndicesY(:), ...
                                     imageIndicesX(:), ...
                                     cameraPixelIndicesY(:), ...
                                     cameraPixelIndicesX(:));
            
end

function [ columns ] = computeColumnIndicesForP(pixelIndexMatrixY, ...
                                                pixelIndexMatrixX, ...
                                                layer, ...
                                                NumberOfLayers, ...
                                                layerResolution)

                                            
layerPixelIndicesY = find(pixelIndexMatrixY(:, 1)); % column vector
layerPixelIndicesX = find(pixelIndexMatrixX(1, :)); % row vector

layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

layerIndices = layer + zeros(size(layerPixelIndicesY));

% convert the subscripts to column indices
columns = sub2ind([layerResolution NumberOfLayers], layerPixelIndicesY(:), ...
                                                    layerPixelIndicesX(:), ...
                                                    layerIndices(:));

end