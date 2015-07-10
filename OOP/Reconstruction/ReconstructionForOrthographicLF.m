classdef ReconstructionForOrthographicLF < AbstractReconstruction
    
    properties
    end
    
    methods
        
        function this = ReconstructionForOrthographicLF()
        end
        
    end
    
    methods (Access = protected)
        
        function constructPropagationMatrix(this)
            
            % 2D pixel positions (relative to one layer) in coordinates of the light field
%             [posX, posY] = pixelToSpaceCoordinates(lightFieldResolution([4, 3]), layerSize, originOfLightField);
            posY = this.lightField.sensorPlane.pixelPositionMatrixY;
            posX = this.lightField.sensorPlane.pixelPositionMatrixX;
            % The scale is 1 / pixelSize, it is used to go from space coordinates back to
            % pixel indices
%             scale = lightFieldResolution([4, 3]) ./ layerSize;

            for imageX = 1 : lightFieldResolution(2)
                for imageY = 1 : lightFieldResolution(1)

                    % compute relative angles for incoming rays from current view
%                     [angleX, angleY] = computeRayAngles(imageX, imageY, fov, lightFieldResolution([2, 1]));
                    [angleX, angleY] = lightField.rayAngle(imageY, imageX);

                    % intersection points of rays with relative angles [angleX, angleY]
                    % on the first layer (most bottom layer), can go outside of layer
                    % boudaries
                    posXL1 = posX + (originOfLayers(3) - originOfLightField(3)) * angleX;
                    posYL1 = posY + (originOfLayers(3) - originOfLightField(3)) * angleY;

                    for layer = 1 : NumberOfLayers

                        % shift intersection points according to current layer
                        posXCurrentLayer = posXL1 - (layer - 1) * distanceBetweenLayers * angleX;
                        posYCurrentLayer = posYL1 - (layer - 1) * distanceBetweenLayers * angleY;

                        % pixel indices 
                        pixelsX = ceil(scale(1) * (posXCurrentLayer - originOfLayers(1)));
                        pixelsY = ceil(scale(2) * (posYCurrentLayer - originOfLayers(2)));

                        % pixels indices outside of bounds get removed
                        pixelsX(pixelsX > lightFieldResolution(4)) = 0;
                        pixelsX(pixelsX < 1) = 0;
                        pixelsY(pixelsY > lightFieldResolution(3)) = 0;
                        pixelsY(pixelsY < 1) = 0;

                        % pick out the indices that are inside bounds
                        indicesX = find(pixelsX);
                        indicesY = find(pixelsY);

                        % make as many copies of the X-indices as there are Y-indices
                        indicesX = repmat(indicesX, numel(indicesY), 1);
                        % make as many copies of the Y-indices as there are X-indices
                        indicesY = repmat(indicesY', 1, size(indicesX, 2));

                        % make copies of the image indices
                        imageIndicesX = imageX + zeros(size(indicesX));
                        imageIndicesY = imageY + zeros(size(indicesX));

                        % convert the 4D subscipts to row indices all at once
                        rows = sub2ind(lightFieldResolution, imageIndicesY(:), imageIndicesX(:), indicesY(:), indicesX(:));

                        % !!! Note: Here, light field resolution is the same as layer
                        % resolution. Support for different light field and layer
                        % resolution is currently not supported !!!
                        layerIndices = layer + zeros(size(indicesX));

                        pixelsX = pixelsX(pixelsX ~= 0);
                        pixelsY = pixelsY(pixelsY ~= 0);
                        indicesX = repmat(pixelsX, [numel(pixelsY) 1]);
                        indicesY = repmat(pixelsY', [1 size(pixelsX,2)]);  

                        % convert the subscripts to column indices
                        columns = sub2ind([lightFieldResolution([3, 4]) NumberOfLayers], indicesY(:), indicesX(:), layerIndices(:));

                        % insert the calculated indices into the sparse arrays
                        numInsertions = numel(rows);
                        I(c : c + numInsertions - 1) = rows;
                        J(c : c + numInsertions - 1) = columns;

                        c = c + numInsertions ;
                    end
                end
            end
            
            
        end
        
        function runOptimization(this)
        end
        
        function [X, Y] = projection(this, ~, targetPlaneZ, X, Y, Z)
            
            X = X + tan(rayAngleX) * (targetPlaneZ - Z);
            
        end
        
        function weightMatrix = computeRayIntersectionWeights(this, ...
                                                              pixelIndexMatrixY, ...
                                                              pixelIndexMatrixX, ...
                                                              intersectionMatrixY, ...
                                                              intersectionMatrixX)
        end
        
    end
    
end

