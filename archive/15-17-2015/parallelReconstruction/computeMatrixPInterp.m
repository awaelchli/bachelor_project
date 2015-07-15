function [ P ] = computeMatrixPInterp( NumberOfLayers, ...
                                 lightFieldResolution, ...
                                 layerResolution, ...
                                 layerSize, ...
                                 fov, ...
                                 distanceBetweenLayers, ...
                                 cameraPlaneDistance, ...
                                 distanceBetweenTwoCameras, ...
                                 distanceCameraPlaneToSensorPlane)
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
% NumberOfNonZeroElements = prod(lightFieldResolution) * NumberOfLayers; 
NumberOfNonZeroElements = 10000000;

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(lightFieldResolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ layerPositionMatrixY, layerPositionMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize([2, 1]));
                                                                          
layerPositionsZ = -(NumberOfLayers - 1) * distanceBetweenLayers / 2 : distanceBetweenLayers : (NumberOfLayers - 1) * distanceBetweenLayers / 2;

sigma_p = 1;
r = 1;
sumW = 0;
for sy = -r:r
    for sx = -r:r
        sumW = sumW + exp(-(sy*sy+sx*sx)/(2*sigma_p*sigma_p));
    end
end

P = sparse(prod(lightFieldResolution), prod([ NumberOfLayers layerResolution ]));




for camIndexX = 1 : lightFieldResolution(2)
    for camIndexY = 1 : lightFieldResolution(1)
    
        % get the position of the current camera on the camera plane
        cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                           cameraPositionMatrixX(camIndexY, camIndexX) ];
        
        for layer = 1 : NumberOfLayers            
            % adjust distance for current layer; the coordinate origin is
            % at the center of the layer stack
            distanceBetweenCameraPlaneAndLayer = cameraPlaneDistance + layerPositionsZ(layer);
            
            % computing the relative location of the intersecting rays
            % between the current camera and layer
            [ pixelPositionMatrixY, ... 
              pixelPositionMatrixX ] = computePixelPositionsOnSensorPlaneRelativeToCamera( ...
                                                               cameraPosition, ... 
                                                               distanceCameraPlaneToSensorPlane, ...
                                                               distanceBetweenCameraPlaneAndLayer, ...
                                                               layerPositionMatrixY, ...
                                                               layerPositionMatrixX);
                                                           
            % converting the metric positions to pixel indicies
            [ pixelIndexMatrixY, ...
              pixelIndexMatrixX, ...
              weightMatrix ] = computePixelIndicesForCamera( ...
                                                               pixelPositionMatrixY, ...
                                                               pixelPositionMatrixX, ...
                                                               distanceCameraPlaneToSensorPlane, ...
                                                               fov([2, 1]), ...
                                                               lightFieldResolution([3, 4]), ...
                                                               @round);
            
            
                                                           
            I = zeros(NumberOfNonZeroElements, 1);      % row indices
            J = zeros(NumberOfNonZeroElements, 1);      % column indices  
            S = ones(NumberOfNonZeroElements, 1);       % values
            c = 1;
            
            
            % insert the calculated indices into the sparse arrays
            for sy = -r:r
                for sx = -r:r

                    tempPixelIndexMatrixY = min(pixelIndexMatrixY+sy, lightFieldResolution(3));
                    tempPixelIndexMatrixY = max(tempPixelIndexMatrixY, 0);
                    
                    tempPixelIndexMatrixX = min(pixelIndexMatrixX+sx, lightFieldResolution(4));
                    tempPixelIndexMatrixX = max(tempPixelIndexMatrixX, 0);
                    
                    columns = computeColumnIndicesForP(tempPixelIndexMatrixY, ...
                                   tempPixelIndexMatrixX, ...
                                   layer, ...
                                   NumberOfLayers, ...
                                   layerResolution);

                    rows = computeRowIndicesForP(camIndexY, ...
                                                 camIndexX, ...
                                                 tempPixelIndexMatrixY, ... 
                                                 tempPixelIndexMatrixX, ...
                                                 lightFieldResolution);
                    
                    numInsertions = numel(rows);
                    w = exp(-(sy*sy+sx*sx)/(2*sigma_p*sigma_p))/sumW;
                    I(c : c + numInsertions-1) = rows;
                    J(c : c + numInsertions-1) = columns;
                    S(c : c + numInsertions-1) = ones(1, numInsertions) * w;
                    c = c + numInsertions;

                end
            end
            
           
            P = P + sparse(I(1:c-1), J(1:c-1), S(1:c-1), prod(lightFieldResolution), prod([ NumberOfLayers layerResolution ]), numel(I));
            
            fprintf('View: (%i, %i) \n', camIndexY, camIndexX);
        end
    end
end



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

% rows = sub2ind(lightFieldResolution([3, 4, 1, 2]), cameraPixelIndicesY(:), ...
%                                                    cameraPixelIndicesX(:), ...
%                                                    imageIndicesY(:), ...
%                                                    imageIndicesX(:));
                                               
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