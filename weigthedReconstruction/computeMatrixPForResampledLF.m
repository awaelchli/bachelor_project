function [ P, resampledLightField ] = computeMatrixPForResampledLF( NumberOfLayers, ...
                                                                    layerResolution, ...
                                                                    layerSize, ...
                                                                    distanceBetweenLayers, ...
                                                                    cameraPlaneDistance, ...
                                                                    distanceBetweenTwoCameras, ...
                                                                    weightFunctionHandle, ...
                                                                    boxRadius, ...
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

Is = cell(lightFieldResolution(1), lightFieldResolution(2), NumberOfLayers);
Js = cell(size(Is));
Ss = cell(size(Is));

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(lightFieldResolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ pixelPositionsOnFirstLayerMatrixY, pixelPositionsOnFirstLayerMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize([2, 1]));

[ pixelIndexOnFirstLayerMatrixX, pixelIndexOnFirstLayerMatrixY ] = meshgrid(1 : layerResolution(2), 1 : layerResolution(1));

layerPositionsZ = -(NumberOfLayers - 1) * distanceBetweenLayers / 2 : distanceBetweenLayers : (NumberOfLayers - 1) * distanceBetweenLayers / 2;
sensorPlaneZ = 0;

fprintf('Views done: \n');

resampledLightField = zeros(size(lightField));

% Pre-compute the column indices for the first layer
columnsForFirstLayer = computeColumnIndicesForP(pixelIndexOnFirstLayerMatrixY, ...
                                           pixelIndexOnFirstLayerMatrixX, ...
                                           1, ...
                                           NumberOfLayers, ...
                                           layerResolution);

for camIndexX = 1 : lightFieldResolution(2)
    for camIndexY = 1 : lightFieldResolution(1)
        
    
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
                                                                    layerSize([2, 1]), ...
                                                                    @round );
        
        invalidRayIndicesForSensorY = sensorIntersectionMatrixY(:, 1) == 0;
        invalidRayIndicesForSensorX = sensorIntersectionMatrixX(1, :) == 0;
        
        pixelIndexOnSensorMatrixY = pixelIndexOnFirstLayerMatrixY;
        pixelIndexOnSensorMatrixX = pixelIndexOnFirstLayerMatrixX;
        
        % TODO: check if necessary
        pixelIndexOnSensorMatrixY(invalidRayIndicesForSensorY, :) = 0;
        pixelIndexOnSensorMatrixX(:, invalidRayIndicesForSensorX) = 0;
        
        % Interpolating the current view of the light field
        view = squeeze(lightField(camIndexY, camIndexX, :, :, :));
        [Yq, Xq, Cq] = ndgrid(sensorIntersectionMatrixY(:, 1), sensorIntersectionMatrixX(1, :), 1 : channels);
        resampledLightField(camIndexY, camIndexX, :, :, :) = interp3(view, Xq, Yq, Cq);
        
        rowsForFirstLayer = computeRowIndicesForP(camIndexY, ...
                                     camIndexX, ...
                                     pixelIndexOnSensorMatrixY, ... 
                                     pixelIndexOnSensorMatrixX, ...
                                     lightFieldResolution);

        % Insert indices and values for the first layer
        Is{camIndexY, camIndexX, 1} = rowsForFirstLayer;
        Js{camIndexY, camIndexX, 1} = columnsForFirstLayer;
        Ss{camIndexY, camIndexX, 1} = ones(size(rowsForFirstLayer));
        
        for sy = -boxRadius : boxRadius
            for sx = -boxRadius : boxRadius
        
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
                                                                               layerSize([2, 1]), ...
                                                                               @round );
                                                                           
                    tempPixelIndexOnLayerMatrixY = min(pixelIndexOnLayerMatrixY + sy, layerResolution(1));
                    tempPixelIndexOnLayerMatrixY = max(tempPixelIndexOnLayerMatrixY, 0);
                    tempPixelIndexOnLayerMatrixX = min(pixelIndexOnLayerMatrixX + sx, layerResolution(2));
                    tempPixelIndexOnLayerMatrixX = max(tempPixelIndexOnLayerMatrixX, 0);

                    weightsForLayerMatrix = computeRayIntersectionWeights( tempPixelIndexOnLayerMatrixY, ...
                                                                           tempPixelIndexOnLayerMatrixX, ...
                                                                           layerIntersectionMatrixY, ...
                                                                           layerIntersectionMatrixX, ...
                                                                           weightFunctionHandle );

                    tempPixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
                    tempPixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;

                    layerPixelIndicesY = tempPixelIndexOnLayerMatrixY(tempPixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
                    layerPixelIndicesX = tempPixelIndexOnLayerMatrixX(1, tempPixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

                    layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
                    layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

                    layerIndices = layer + zeros(size(layerPixelIndicesY));

                    % convert the subscripts to column indices
                    columns = sub2ind([layerResolution NumberOfLayers], layerPixelIndicesY(:), ...
                                                                        layerPixelIndicesX(:), ...
                                                                        layerIndices(:));

                    invalidRayIndicesForLayerY = tempPixelIndexOnLayerMatrixY(:, 1) == 0;
                    invalidRayIndicesForLayerX = tempPixelIndexOnLayerMatrixX(1, :) == 0;

                    tempPixelIndexOnSensorMatrixY = pixelIndexOnSensorMatrixY;
                    tempPixelIndexOnSensorMatrixX = pixelIndexOnSensorMatrixX;

                    tempPixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
                    tempPixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;

                    rows = computeRowIndicesForP(camIndexY, ...
                                                 camIndexX, ...
                                                 tempPixelIndexOnSensorMatrixY, ... 
                                                 tempPixelIndexOnSensorMatrixX, ...
                                                 lightFieldResolution);

                    weights = weightsForLayerMatrix;
                    weights = weights(~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY), :);
                    weights = weights(: , ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX));
                    
                    Is{camIndexY, camIndexX, layer} = rows;
                    Js{camIndexY, camIndexX, layer} = columns;
                    Ss{camIndexY, camIndexX, layer} = weights(:);
                end
            end
        end
        
        fprintf('(%i, %i)\n', camIndexY, camIndexX);
    end
end

P = sparse([Is{:}], [Js{:}], [Ss{:}], prod(lightFieldResolution), prod([ NumberOfLayers layerResolution ]));

% rowSums = sum(P, 2);
% rowSums = max(1, rowSums);
% P = spdiags(1 ./ rowSums, 0, size(P, 1), size(P,1)) * P;

% colSums = sum(P, 1);
% colSums = max(1, colSums);
% P = P * spdiags(1 ./ colSums', 0, size(P, 2), size(P, 2));

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
% TODO: compare performance: use repmat instead of adding to zero vector
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

% TODO: compare performance: use repmat instead of adding to zero vector
layerIndices = layer + zeros(size(layerPixelIndicesY));

% convert the subscripts to column indices
columns = sub2ind([layerResolution NumberOfLayers], layerPixelIndicesY(:), ...
                                                    layerPixelIndicesX(:), ...
                                                    layerIndices(:));

end