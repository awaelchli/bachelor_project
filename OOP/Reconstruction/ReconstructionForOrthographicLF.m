classdef ReconstructionForOrthographicLF < AbstractReconstruction
    
    methods
        
        function this = ReconstructionForOrthographicLF(lightField, attenuator)
            this = this@AbstractReconstruction(lightField, attenuator);
            
            lightFieldData = zeros([this.lightField.resolution, this.lightField.channels]);
            reconstructedLightField = LightFieldO(lightFieldData, lightField.sensorPlane, lightField.fov);
            this.evaluation = ReconstructionEvaluation(this.lightField, attenuator, reconstructedLightField);
            
            this.propagationMatrix = PropagationMatrix(this.lightField, attenuator);
        end
        
    end
    
    methods (Access = protected)
        
        function lightField = getLightFieldForOptimization(this)
            lightField = this.lightField;
        end
        
        function constructPropagationMatrix(this)
            
            % 2D pixel positions (relative to one layer) in coordinates of the light field
%             [posX, posY] = pixelToSpaceCoordinates(lightFieldResolution([4, 3]), layerSize, originOfLightField);
            posY = this.lightField.sensorPlane.pixelPositionMatrixY;
            posX = this.lightField.sensorPlane.pixelPositionMatrixX;
            % The scale is 1 / pixelSize, it is used to go from space coordinates back to
            % pixel indices
%             scale = lightFieldResolution([4, 3]) ./ layerSize;
%             firstLayerZ = this.attenuator.layerPositionZ(1);

            for imageX = 1 : this.lightField.angularResolution(2)
                for imageY = 1 : this.lightField.angularResolution(1)

                    % compute relative angles for incoming rays from current view
%                     [angleX, angleY] = computeRayAngles(imageX, imageY, fov, lightFieldResolution([2, 1]));
%                     [angleX, angleY] = lightField.rayAngle(imageY, imageX);

                    % intersection points of rays with relative angles [angleX, angleY]
                    % on the first layer (most bottom layer), can go outside of layer
                    % boudaries
                    
                    
                    
%                     posXL1 = posX + (originOfLayers(3) - originOfLightField(3)) * angleX;
%                     posYL1 = posY + (originOfLayers(3) - originOfLightField(3)) * angleY;

                    for layer = 1 : this.attenuator.numberOfLayers

                        [posXCurrentLayer, ...
                         posYCurrentLayer] = this.projection([imageY, imageX], ...
                                                             this.attenuator.layerPositionZ(layer), ...
                                                             posX, ...
                                                             posY, ...
                                                             this.lightField.sensorPlane.z);
                                                   
%                         posXCurrentLayer = posXL1 - (layer - 1) * distanceBetweenLayers * angleX;
%                         posYCurrentLayer = posYL1 - (layer - 1) * distanceBetweenLayers * angleY;

                        % pixel indices 
%                         pixelsX = ceil(scale(1) * (posXCurrentLayer - originOfLayers(1)));
%                         pixelsY = ceil(scale(2) * (posYCurrentLayer - originOfLayers(2)));

                        [pixelsY, ...
                         pixelsX, ...
                         validIndices] = this.attenuator.positionToPixelCoordinates(posYCurrentLayer, ...
                                                                                    posXCurrentLayer);
                                                                                
                        
%                         % pixels indices outside of bounds get removed
%                         pixelsX(pixelsX > lightFieldResolution(4)) = 0;
%                         pixelsX(pixelsX < 1) = 0;
%                         pixelsY(pixelsY > lightFieldResolution(3)) = 0;
%                         pixelsY(pixelsY < 1) = 0;

                        validX = sum(validIndices, 1) ~= 0;
                        validY = sum(validIndices, 2) ~= 0;
                        
                        indicesY = find(validY);
                        indicesX = find(validX);
                        % pick out the indices that are inside bounds
%                         indicesX = find(pixelsX);
%                         indicesY = find(pixelsY);

                        % make as many copies of the X-indices as there are Y-indices
                        indicesX = repmat(indicesX, numel(indicesY), 1);
                        % make as many copies of the Y-indices as there are X-indices
%                         indicesY = repmat(indicesY', 1, size(indicesX, 2));
                        indicesY = repmat(indicesY, 1, size(indicesX, 2));

                        % make copies of the image indices
%                         imageIndicesX = imageX + zeros(size(indicesX));
%                         imageIndicesY = imageY + zeros(size(indicesX));

                        % convert the 4D subscipts to row indices all at once
%                         rows = sub2ind(lightFieldResolution, imageIndicesY(:), imageIndicesX(:), indicesY(:), indicesX(:));

                        % !!! Note: Here, light field resolution is the same as layer
                        % resolution. Support for different light field and layer
                        % resolution is currently not supported !!!
%                         layerIndices = layer + zeros(size(indicesX));
% 
%                         pixelsX = pixelsX(pixelsX ~= 0);
%                         pixelsY = pixelsY(pixelsY ~= 0);
%                         indicesX = repmat(pixelsX, [numel(pixelsY) 1]);
%                         indicesY = repmat(pixelsY', [1 size(pixelsX,2)]);  

                        % convert the subscripts to column indices
%                         columns = sub2ind([lightFieldResolution([3, 4]) NumberOfLayers], indicesY(:), indicesX(:), layerIndices(:));

                        % insert the calculated indices into the sparse arrays
%                         numInsertions = numel(rows);
%                         I(c : c + numInsertions - 1) = rows;
%                         J(c : c + numInsertions - 1) = columns;
                        pixelsY = pixelsY(validY, validX);
                        pixelsX = pixelsX(validY, validX);
                        
                        pixelsY = round(pixelsY);
                        pixelsX = round(pixelsX);
                        
                        this.propagationMatrix.submitEntries(imageY, imageX, ...
                                                             indicesY, indicesX, ...
                                                             layer, ...
                                                             pixelsY, pixelsX, ...
                                                             ones(size(pixelsY)));
%                         c = c + numInsertions ;
                    end
                end
            end
            
            
        end
        
        function [X, Y] = projection(this, cameraIndex, targetPlaneZ, X, Y, Z)
            
            rayAngle = this.lightField.rayAngle(cameraIndex);
            Y = Y + tan(rayAngle(1)) * (targetPlaneZ - Z);
            X = X + tan(rayAngle(2)) * (targetPlaneZ - Z);
        end
        
        function weightMatrix = computeRayIntersectionWeights(this, ...
                                                              pixelIndexMatrixY, ...
                                                              pixelIndexMatrixX, ...
                                                              intersectionMatrixY, ...
                                                              intersectionMatrixX)
            weightMatrix = ones(size(pixelIndexMatrixY));
        end
        
    end
    
end

