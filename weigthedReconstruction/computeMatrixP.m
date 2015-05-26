function [ P ] = computeMatrixP( NumberOfLayers, ...
                                 lightFieldResolution, ...
                                 layerResolution, ...
                                 layerSize, ...
                                 distanceBetweenLayers, ...
                                 cameraPlaneDistance, ...
                                 distanceBetweenTwoCameras, ...
                                 weightFunctionHandle )
% Inputs:
%
%   NumberOfLayers:                 Number of layers in the attenuator
%   lightFieldResolution:           The resolution of the light field
%                                   [viewsY, viewsX, pixelsY, pixelsX]
%   layerResolution:                Resolution of the layers [resY, resX]
%   layersSize:                     Size of the layer in mm [width, height]
%   fov:                            The field of view [fovX, fovY] in X and
%                                   Y direction of the cameras in radians
%   distanceBetweenLayers:          Distance between the layers in mm
%   cameraPlaneDistance:            Distance between the camera plane and
%                                   the origin of the scene in mm
%   distanceBetweenTwoCameras:      distance between two cameras on the
%                                   camera plane in mm
%   distanceCameraPlaneToSensorPlane:   Distance between camera plane and
%                                   sensor plane in mm
%
% Output:
%
%   P:              The propagation matrix, describing where each ray hits
%                   each layer

% upper bound for number of non-zero values in the matrix P
NumberOfNonZeroElements = prod(lightFieldResolution) * NumberOfLayers; 
NumberOfNonZeroElements = 100000000;

I = zeros(NumberOfNonZeroElements, 1);      % row indices
J = zeros(NumberOfNonZeroElements, 1);      % column indices  
S = zeros(NumberOfNonZeroElements, 1);       % values

% index of the current non-zero element used in the for loop below.
c = 1;

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(lightFieldResolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ pixelPositionsOnFirstLayerMatrixY, pixelPositionsOnFirstLayerMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize([2, 1]));
                                                                          
layerPositionsZ = -(NumberOfLayers - 1) * distanceBetweenLayers / 2 : distanceBetweenLayers : (NumberOfLayers - 1) * distanceBetweenLayers / 2;
sensorPlaneZ = 0;

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
        [ pixelIndexOnSensorMatrixY, ...
          pixelIndexOnSensorMatrixX, ...
          weightsForSensorMatrix ] = computePixelIndicesOnPlane( positionsOnSensorPlaneMatrixY, ...
                                                               positionsOnSensorPlaneMatrixX, ...
                                                               lightFieldResolution([3, 4]), ...
                                                               layerSize([2, 1]), ...
                                                               @round, ...
                                                               weightFunctionHandle );
                                                           
        columns = computeColumnIndicesForP(pixelIndexOnSensorMatrixY, ...
                                   pixelIndexOnSensorMatrixX, ...
                                   1, ...
                                   NumberOfLayers, ...
                                   layerResolution);

        rows = computeRowIndicesForP(camIndexY, ...
                                                 camIndexX, ...
                                                 pixelIndexOnSensorMatrixY, ... 
                                                 pixelIndexOnSensorMatrixX, ...
                                                 lightFieldResolution);
                                             
        invalidRayIndicesForSensorY = pixelIndexOnSensorMatrixY(:, 1) == 0;
        invalidRayIndicesForSensorX = pixelIndexOnSensorMatrixX(1, :) == 0;
        
        %debug
%         numel(invalidRayIndicesForSensorY)
%         numel(invalidRayIndicesForSensorX)
        
        numInsertions = numel(rows);
        I(c : c + numInsertions - 1) = rows;
        J(c : c + numInsertions - 1) = columns;
        S(c : c + numInsertions - 1) = weightsForSensorMatrix(:);
        c = c + numInsertions;
        
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
              weightsForLayerMatrix ] = computePixelIndicesOnPlane( positionsOnLayerMatrixY, ...
                                                              positionsOnLayerMatrixX, ...
                                                              layerResolution, ...
                                                              layerSize([2, 1]), ...
                                                              @round, ...
                                                              weightFunctionHandle);
                                                          
            pixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
            pixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;
            
            layerPixelIndicesY = pixelIndexOnLayerMatrixY(pixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
            layerPixelIndicesX = pixelIndexOnLayerMatrixX(1, pixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

            layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
            layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

            layerIndices = layer + zeros(size(layerPixelIndicesY));

            % convert the subscripts to column indices
            columns = sub2ind([layerResolution NumberOfLayers], layerPixelIndicesY(:), ...
                                                                layerPixelIndicesX(:), ...
                                                                layerIndices(:));
                                                            
                                                            
            invalidRayIndicesForLayerY = pixelIndexOnLayerMatrixY(:, 1) == 0;
            invalidRayIndicesForLayerX = pixelIndexOnLayerMatrixX(1, :) == 0;
            
            tempPixelIndexOnSensorMatrixY = pixelIndexOnSensorMatrixY;
            tempPixelIndexOnSensorMatrixX = pixelIndexOnSensorMatrixX;
            
            tempPixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
            tempPixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;
            
            rows = computeRowIndicesForP(camIndexY, ...
                                                 camIndexX, ...
                                                 tempPixelIndexOnSensorMatrixY, ... 
                                                 tempPixelIndexOnSensorMatrixX, ...
                                                 lightFieldResolution);
%             numel(columns)
%             numel(rows)
            
            numInsertions = numel(rows);
                       
            % TODO: compare adding weights together instead of multiplying
            weights = weightsForLayerMatrix .* weightsForSensorMatrix;
            weights = weights(~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY), :);
            weights = weights(: , ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX));
            
            % insert the calculated indices and weights into the sparse arrays
            I(c : c + numInsertions - 1) = rows;
            J(c : c + numInsertions - 1) = columns;
            S(c : c + numInsertions - 1) = weights(:);
            c = c + numInsertions;

        end
    end
end

I = I(1 : c - 1);
J = J(1 : c - 1);
S = S(1 : c - 1);

P = sparse(I, J, S, prod(lightFieldResolution), prod([ NumberOfLayers layerResolution ]), c - 1);


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