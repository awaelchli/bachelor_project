function [ P ] = computeMatrixP( Nlayers, ...
                                 resolution, ...
                                 layerResolution, ...
                                 layerSize, ...
                                 originLF, ...
                                 originLayers, ...
                                 fov, ...
                                 layerDist, ...
                                 planeDist, ...
                                 distanceBetweenTwoCameras, ...
                                 focalLength)
% Inputs:
%
%   Nlayers:        The number of layers in the attenuator
%   resolution:     The resolution of the light field [viewsY, viewsX, pixelsY, pixelsX]
%   layersSize:     The size of the layer in millimeters [width, height]
%   originLF:       The origin of the light field relative to the origin of
%                   the attenuator
%   originLayers:   The origin of the attenuator
%   fov:            The field of view [fovX, fovY] in Y and X direction of 
%                   the light field (not the fov of the cameras)
%   layerDist:      The distance between the layers
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

% % 2D pixel positions (relative to one layer) in coordinates of the light field
% [posX, posY] = pixelToSpaceCoordinates(resolution([4, 3]), layerSize, originLF);
% % The scale is 1 / pixelSize, it is used to go from space coordinates back to
% % pixel indices
% scale = resolution([4, 3]) ./ layerSize;

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(resolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ layerPositionMatrixY, layerPositionMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize([2, 1]));

layerPositionsZ = (Nlayers - 1) * layerDist : -layerDist : 0;
layerPositionsZ = layerPositionsZ + originLF(3);

for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        
        % compute relative angles for incoming rays from current view
        %[angleX, angleY] = computeRayAngles(imageX, imageY, fov, resolution([2, 1]));
       
        % intersection points of rays with relative angles [angleX, angleY]
        % on the first layer (most bottom layer), can go outside of layer
        % boudaries
%         posXL1 = posX + (originLayers(3) - originLF(3)) * angleX;
%         posYL1 = posY + (originLayers(3) - originLF(3)) * angleY;
        cameraPosition = [ cameraPositionMatrixY(imageY, imageX), ...
                           cameraPositionMatrixX(imageY, imageX) ];
        
        for layer = 1 : Nlayers
            
            % shift intersection points according to current layer
%             posXCurrentLayer = posXL1 - (layer - 1) * layerDist * angleX;
%             posYCurrentLayer = posYL1 - (layer - 1) * layerDist * angleY;
%             
%             % pixel indices 
%             pixelsX = ceil(scale(1) * (posXCurrentLayer - originLayers(1)));
%             pixelsY = ceil(scale(2) * (posYCurrentLayer - originLayers(2)));

            distanceBetweenCameraPlaneAndLayer = planeDist - layerPositionsZ(layer);
            
            [ pixelPositionMatrixY, ... 
              pixelPositionMatrixX ] = computePixelPositionsOnSensorPlaneRelativeToCamera( ...
                                                               cameraPosition, ... 
                                                               focalLength, ...
                                                               distanceBetweenCameraPlaneAndLayer, ...
                                                               layerPositionMatrixY, ...
                                                               layerPositionMatrixX);
                                                           
            [ pixelIndexMatrixY, ...
              pixelIndexMatrixX ] = computePixelIndicesForCamera( ...
                                                               pixelPositionMatrixY, ...
                                                               pixelPositionMatrixX, ...
                                                               focalLength, ...
                                                               fov([2, 1]), ...
                                                               resolution([3, 4]));


            [ layerPixelIndicesY, ~ ] = find(pixelIndexMatrixY);
            [ ~, layerPixelIndicesX ] = find(pixelIndexMatrixX);
            
            layerPixelIndicesY = unique(layerPixelIndicesY);
            layerPixelIndicesX = unique(layerPixelIndicesX);
            
            layerPixelIndicesY = repmat(layerPixelIndicesY', 1, numel(layerPixelIndicesX)); 
            layerPixelIndicesX = repmat(layerPixelIndicesX, numel(layerPixelIndicesY), 1); 
            
            % !!! Note: Here, light field resolution is the same as layer
            % resolution. Support for different light field and layer
            % resolution is currently not supported !!!
            layerIndices = layer + zeros(size(layerPixelIndicesY));
            
            % convert the subscripts to column indices
            columns = sub2ind([resolution([3, 4]) Nlayers], layerPixelIndicesY(:), layerPixelIndicesX(:), layerIndices(:));
            
            cameraPixelIndicesY = pixelIndexMatrixY(pixelIndexMatrixY ~= 0);
            cameraPixelIndicesX = pixelIndexMatrixX(pixelIndexMatrixX ~= 0);

            % make copies of the image indices
            imageIndicesY = imageY + zeros(size(cameraPixelIndicesY));
            imageIndicesX = imageX + zeros(size(cameraPixelIndicesX));
            
            % convert the 4D subscipts to row indices all at once
            rows = sub2ind(resolution, imageIndicesY(:), imageIndicesX(:), cameraPixelIndicesY(:), cameraPixelIndicesX(:));
     
            % insert the calculated indices into the sparse arrays
            numInsertions = numel(rows);
            I(c : c + numInsertions - 1) = rows;
            J(c : c + numInsertions - 1) = columns;
            
            c = c + numInsertions ;
        end
    end
end

P = sparse(I(1:c - 1), J(1:c - 1), S(1:c - 1), prod(resolution), prod([Nlayers resolution([3, 4])]), c - 1);

end

