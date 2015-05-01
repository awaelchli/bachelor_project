function [ P ] = computeMatrixP( NumberOfLayers, ...
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
maxNonZeros = prod(lightFieldResolution) * NumberOfLayers; 

I = zeros(maxNonZeros, 1);      % row indices
J = zeros(maxNonZeros, 1);      % column indices  
S = ones(maxNonZeros, 1);       % values

% index of the current non-zero element used in the for loop below.
c = 1;

[ cameraPositionMatrixY, cameraPositionMatrixX ] = computeCameraPositions(lightFieldResolution([1, 2]), ...
                                                                          distanceBetweenTwoCameras([2, 1]));

[ layerPositionMatrixY, layerPositionMatrixX ] = computePixelPositionsOnLayer(layerResolution, ...
                                                                              layerSize([2, 1]));

layerPositionsZ = -(NumberOfLayers - 1) * distanceBetweenLayers / 2 : distanceBetweenLayers : (NumberOfLayers - 1) * distanceBetweenLayers / 2;

for camIndexX = 1 : lightFieldResolution(2)
    for camIndexY = 1 : lightFieldResolution(1)
    
        % get the position of the current camera on the camera plane
        cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                           cameraPositionMatrixX(camIndexY, camIndexX) ];
                       
%         cameraPosition
        
        for layer = 1 : NumberOfLayers
            
            % adjust distance for current layer; the coordinate origin is
            % at the center of the layer stack
            distanceBetweenCameraPlaneAndLayer = cameraPlaneDistance + layerPositionsZ(layer);
            
            
%             distanceBetweenCameraPlaneAndLayer
            
            % computing the relative location of the intersecting rays
            % between the current camera and layer
            [ pixelPositionMatrixY, ... 
              pixelPositionMatrixX ] = computePixelPositionsOnSensorPlaneRelativeToCamera( ...
                                                               cameraPosition, ... 
                                                               distanceCameraPlaneToSensorPlane, ...
                                                               distanceBetweenCameraPlaneAndLayer, ...
                                                               layerPositionMatrixY, ...
                                                               layerPositionMatrixX);

%            pixelPositionMatrixY
%            pixelPositionMatrixX

            % converting the metric positions to pixel indicies
%             [ pixelIndexMatrixYFloor, ...
%               pixelIndexMatrixXFloor ] = computePixelIndicesForCamera( ...
%                                                                pixelPositionMatrixY, ...
%                                                                pixelPositionMatrixX, ...
%                                                                focalLength, ...
%                                                                fov([2, 1]), ...
%                                                                resolution([3, 4]), ...
%                                                                @floor);
%                                                            
%             [ pixelIndexMatrixYCeil, ...
%               pixelIndexMatrixXCeil ] = computePixelIndicesForCamera( ...
%                                                                pixelPositionMatrixY, ...
%                                                                pixelPositionMatrixX, ...
%                                                                focalLength, ...
%                                                                fov([2, 1]), ...
%                                                                resolution([3, 4]), ...
%                                                                @ceil);
%             
%             columns = floorCeilCombinationsForColumns(pixelIndexMatrixYFloor, ...
%                                                      pixelIndexMatrixXFloor, ...
%                                                      pixelIndexMatrixYCeil, ...
%                                                      pixelIndexMatrixXCeil, ...
%                                                      layer, ...
%                                                      Nlayers, ...
%                                                      resolution);
%                                             
%             rows = floorCeilCombinationsForRows(camIndexY, ...
%                                                camIndexX, ...
%                                                pixelIndexMatrixYFloor, ...
%                                                pixelIndexMatrixXFloor, ...
%                                                pixelIndexMatrixYCeil, ...
%                                                pixelIndexMatrixXCeil, ...
%                                                resolution);
                                     
            [ pixelIndexMatrixY, ...
              pixelIndexMatrixX ] = computePixelIndicesForCamera( ...
                                                               pixelPositionMatrixY, ...
                                                               pixelPositionMatrixX, ...
                                                               distanceCameraPlaneToSensorPlane, ...
                                                               fov([2, 1]), ...
                                                               lightFieldResolution([3, 4]), ...
                                                               @round);
            
%             pixelIndexMatrixY
            pixelIndexMatrixX
            
            
            columns = computeColumnIndicesForP(pixelIndexMatrixY, ...
                                               pixelIndexMatrixX, ...
                                               layer, ...
                                               NumberOfLayers, ...
                                               layerResolution);
            
            rows = computeRowIndicesForP(camIndexY, ...
                                         camIndexX, ...
                                         pixelIndexMatrixY, ... 
                                         pixelIndexMatrixX, ...
                                         lightFieldResolution);


            % insert the calculated indices into the sparse arrays
            numInsertions = numel(rows);
            I(c : c + numInsertions-1) = rows;
            J(c : c + numInsertions-1) = columns;
            
%             S(c : c + numInsertions-1) = 0.25 * ones(1, numInsertions);
            
            c = c + numInsertions ;
        end
    end
end

P = sparse(I(1:c-1), J(1:c-1), S(1:c-1), prod(lightFieldResolution), prod([NumberOfLayers lightFieldResolution([3, 4])]), c-1);

end


function [ rows ] = computeRowIndicesForP(camIndexY, ...
                                          camIndexX, ...
                                          pixelIndexMatrixY, ... 
                                          pixelIndexMatrixX, ...
                                          lightFieldResolution)

cameraPixelIndicesY = pixelIndexMatrixY(pixelIndexMatrixY(:, 1) ~= 0, 1); % col vector
cameraPixelIndicesX = pixelIndexMatrixX(1, pixelIndexMatrixX(1, :) ~= 0); % row vector

% cameraPixelIndicesY = 1 : resolution(3);
% cameraPixelIndicesY = cameraPixelIndicesY';
% cameraPixelIndicesX = 1 : resolution(4);

cameraPixelIndicesY = repmat(cameraPixelIndicesY, 1, numel(cameraPixelIndicesX)); 
cameraPixelIndicesX = repmat(cameraPixelIndicesX, size(cameraPixelIndicesY, 1), 1); 

% make copies of the image indices
imageIndicesY = camIndexY + zeros(size(cameraPixelIndicesY));
imageIndicesX = camIndexX + zeros(size(cameraPixelIndicesX));

% convert the 4D subscipts to row indices all at once
rows = sub2ind(lightFieldResolution([3, 4, 1, 2]), cameraPixelIndicesY(:), ...
                                                   cameraPixelIndicesX(:), ...
                                                   imageIndicesY(:), ...
                                                   imageIndicesX(:));
            
end

function [ columns ] = computeColumnIndicesForP(pixelIndexMatrixY, ...
                                                pixelIndexMatrixX, ...
                                                layer, ...
                                                Nlayers, ...
                                                layerResolution)

layerPixelIndicesY = find(pixelIndexMatrixY(:, 1)); % col vector
layerPixelIndicesX = find(pixelIndexMatrixX(1, :)); % row vector

% layerPixelIndicesY = 1 : resolution(3);
% layerPixelIndicesY = layerPixelIndicesY';
% layerPixelIndicesX = 1 : resolution(4);

layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

layerIndices = layer + zeros(size(layerPixelIndicesY));


% convert the subscripts to column indices
columns = sub2ind([layerResolution([3, 4]) Nlayers], layerPixelIndicesY(:), layerPixelIndicesX(:), layerIndices(:));

end

% ::::::::::::::::::::::::::::::::::::::::
% CODE FROM TOMOGRAPHIC LF SYNTHESIS PAPER
% ::::::::::::::::::::::::::::::::::::::::
% kick out stuff that's outside
% layerPixelIndicesForRaysX(layerPixelIndicesForRaysX>layerResolution(2)) = 0;
% layerPixelIndicesForRaysX(layerPixelIndicesForRaysX<1) = 0;
% layerPixelIndicesForRaysY(layerPixelIndicesForRaysY>layerResolution(1)) = 0;
% layerPixelIndicesForRaysY(layerPixelIndicesForRaysY<1) = 0;                                        
% 
% % convert to matrix row indices - which rays hit some layer pixels
% validXIndices = find(layerPixelIndicesForRaysX);
% validYIndices = find(layerPixelIndicesForRaysY);
% 
% % turn it into a matrix
% validXIndices = repmat(validXIndices, [numel(validYIndices) 1]);
% validYIndices = repmat(validYIndices', [1 size(validXIndices,2)]);
% % angle indices                    
% validVXIndices = vxIdx + zeros(size(validXIndices));
% validVYIndices = vyIdx + zeros(size(validXIndices));
% 
% % convert 4D subscipts to matrix indices
% matrixRows = sub2ind(lightFieldResolution, validVYIndices(:), validVXIndices(:), validYIndices(:), validXIndices(:));
% 
% % convert to matrix column indices               
% layerPixelIndicesForRaysX = layerPixelIndicesForRaysX(layerPixelIndicesForRaysX~=0);
% layerPixelIndicesForRaysY = layerPixelIndicesForRaysY(layerPixelIndicesForRaysY~=0);
% validXXIndices = repmat(layerPixelIndicesForRaysX, [numel(layerPixelIndicesForRaysY) 1]);
% validYYIndices = repmat(layerPixelIndicesForRaysY', [1 size(layerPixelIndicesForRaysX,2)]);                    
% validZZIndices = layer + zeros(size(validXXIndices));
% 
% % convert 3D subscripts to matrix indices
% matrixColumns   = sub2ind(layerResolution, validYYIndices(:), validXXIndices(:), validZZIndices(:));
%
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function [columns] = floorCeilCombinationsForColumns(pixelIndexMatrixYFloor, ...
                                                     pixelIndexMatrixXFloor, ...
                                                     pixelIndexMatrixYCeil, ...
                                                     pixelIndexMatrixXCeil, ...
                                                     layer, ...
                                                     Nlayers, ...
                                                     resolution)

cFloorYFloorX = computeColumnIndicesForP(pixelIndexMatrixYFloor, ...
                                         pixelIndexMatrixXFloor, ...
                                         layer, ...
                                         Nlayers, ...
                                         resolution);
                                     
cFloorYCeilX = computeColumnIndicesForP(pixelIndexMatrixYFloor, ...
                                         pixelIndexMatrixXCeil, ...
                                         layer, ...
                                         Nlayers, ...
                                         resolution);

cCeilYFloorX = computeColumnIndicesForP(pixelIndexMatrixYCeil, ...
                                         pixelIndexMatrixXFloor, ...
                                         layer, ...
                                         Nlayers, ...
                                         resolution);
                                     
cCeilYCeilX = computeColumnIndicesForP(pixelIndexMatrixYCeil, ...
                                         pixelIndexMatrixXCeil, ...
                                         layer, ...
                                         Nlayers, ...
                                         resolution);

columns = [cFloorYFloorX' cFloorYCeilX' cCeilYFloorX' cCeilYCeilX'];
end


function [rows] = floorCeilCombinationsForRows(camIndexY, ...
                                               camIndexX, ...
                                               pixelIndexMatrixYFloor, ...
                                               pixelIndexMatrixXFloor, ...
                                               pixelIndexMatrixYCeil, ...
                                               pixelIndexMatrixXCeil, ...
                                               resolution)

rFloorYFloorX = computeRowIndicesForP(camIndexY, ...
                                          camIndexX, ...
                                          pixelIndexMatrixYFloor, ... 
                                          pixelIndexMatrixXFloor, ...
                                          resolution);
                                     
rFloorYCeilX = computeRowIndicesForP(camIndexY, ...
                                          camIndexX, ...
                                          pixelIndexMatrixYFloor, ... 
                                          pixelIndexMatrixXCeil, ...
                                          resolution);

rCeilYFloorX = computeRowIndicesForP(camIndexY, ...
                                          camIndexX, ...
                                          pixelIndexMatrixYCeil, ... 
                                          pixelIndexMatrixXFloor, ...
                                          resolution);
                                     
rCeilYCeilX = computeRowIndicesForP(camIndexY, ...
                                          camIndexX, ...
                                          pixelIndexMatrixYCeil, ... 
                                          pixelIndexMatrixXCeil, ...
                                          resolution);
                                     
rows = [rFloorYFloorX' rFloorYCeilX' rCeilYFloorX' rCeilYCeilX'];
end
