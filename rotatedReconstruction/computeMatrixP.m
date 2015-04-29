function [ P ] = computeMatrixP( Nlayers, ...
                                 resolution, ...
                                 layerResolution, ...
                                 layerSize, ...
                                 fov, ...
                                 distanceBetweenLayers, ...
                                 cameraPlaneDistance, ...
                                 distanceBetweenTwoCameras, ...
                                 focalLength)
% Inputs:
%
%   Nlayers:                        Number of layers in the attenuator
%   resolution:                     The resolution of the light field
%                                   [viewsY, viewsX, pixelsY, pixelsX]
%   layersSize:                     Size of the layer in mm [width, height]
%   fov:                            The field of view [fovX, fovY] in X and
%                                   Y direction of the cameras in radians
%   distanceBetweenLayers:          Distance between the layers in mm
%   cameraPlaneDistance:            Distance between the camera plane and
%                                   the origin of the scene in mm
%   distanceBetweenTwoCameras:      distance between two cameras on the
%                                   camera plane in mm
%   focalLength:                    focal length of the cameras in mm
%
% Output:
%
%   P:              The propagation matrix, describing where each ray hits
%                   each layer

% upper bound for number of non-zero values in the matrix P
maxNonZeros = prod(resolution) * Nlayers; 

I = zeros(maxNonZeros, 1);      % row indices
J = zeros(maxNonZeros, 1);      % column indices  
S = ones(maxNonZeros, 1);       % values

% index of the current non-zero element used in the for loop below.
c = 1;

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(resolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ layerPositionMatrixY, layerPositionMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize([2, 1]));

layerPositionsZ = -(Nlayers - 1) * distanceBetweenLayers / 2 : distanceBetweenLayers : (Nlayers - 1) * distanceBetweenLayers / 2;

for camIndexX = 1 : resolution(2)
    for camIndexY = 1 : resolution(1)
    
        % get the position of the current camera on the camera plane
        cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                           cameraPositionMatrixX(camIndexY, camIndexX) ];
        
        for layer = 1 : Nlayers
            
            % adjust distance for current layer; the coordinate origin is
            % at the center of the layer stack
            distanceBetweenCameraPlaneAndLayer = cameraPlaneDistance + layerPositionsZ(layer);
            
            % computing the relative location of the intersecting rays
            % between the current camera and layer
            [ pixelPositionMatrixY, ... 
              pixelPositionMatrixX ] = computePixelPositionsOnSensorPlaneRelativeToCamera( ...
                                                               cameraPosition, ... 
                                                               focalLength, ...
                                                               distanceBetweenCameraPlaneAndLayer, ...
                                                               layerPositionMatrixY, ...
                                                               layerPositionMatrixX);
            % converting the metric positions to pixel indicies
            [ pixelIndexMatrixY, ...
              pixelIndexMatrixX ] = computePixelIndicesForCamera( ...
                                                               pixelPositionMatrixY, ...
                                                               pixelPositionMatrixX, ...
                                                               focalLength, ...
                                                               fov([2, 1]), ...
                                                               resolution([3, 4]));


            layerPixelIndicesY = find(pixelIndexMatrixY(:, 1)); % col vector
            layerPixelIndicesX = find(pixelIndexMatrixX(1, :)); % row vector
            
            layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
            layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 
            
            % !!! Note: Here, light field resolution is the same as layer
            % resolution. Support for different light field and layer
            % resolution is currently not supported !!!
            layerIndices = layer + zeros(size(layerPixelIndicesY));
            
            % convert the subscripts to column indices
            columns = sub2ind([resolution([3, 4]) Nlayers], layerPixelIndicesY(:), layerPixelIndicesX(:), layerIndices(:));
            
            cameraPixelIndicesY = pixelIndexMatrixY(pixelIndexMatrixY(:, 1) ~= 0, 1); % col vector
            cameraPixelIndicesX = pixelIndexMatrixX(1, pixelIndexMatrixX(1, :) ~= 0); % row vector

            cameraPixelIndicesY = repmat(cameraPixelIndicesY, 1, numel(cameraPixelIndicesX)); 
            cameraPixelIndicesX = repmat(cameraPixelIndicesX, size(cameraPixelIndicesY, 1), 1); 

            % make copies of the image indices
            imageIndicesY = camIndexY + zeros(size(cameraPixelIndicesY));
            imageIndicesX = camIndexX + zeros(size(cameraPixelIndicesX));
            
            % convert the 4D subscipts to row indices all at once
            rows = sub2ind(resolution, imageIndicesY(:), imageIndicesX(:), cameraPixelIndicesY(:), cameraPixelIndicesX(:));
     
            % insert the calculated indices into the sparse arrays
            numInsertions = numel(rows);
            I(c : c + numInsertions-1) = rows;
            J(c : c + numInsertions-1) = columns;
            
            c = c + numInsertions ;
        end
    end
end

P = sparse(I(1:c-1), J(1:c-1), S(1:c-1), prod(resolution), prod([Nlayers resolution([3, 4])]), c-1);

end

