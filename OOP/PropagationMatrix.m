classdef PropagationMatrix < handle
    %PROPAGATIONMATRIX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        lightFieldSubscriptRange;
        attenuatorSubscriptRange;
    end
    
    properties (Access = private)
        Is;
        Js;
        Ss;
    end
    
    properties (Dependent, SetAccess = private)
        size;
    end
    
    methods
        
        function self = PropagationMatrix(lightField, attenuator)
            self.lightFieldSubscriptRange = lightField.resolution;
            self.attenuatorSubscriptRange = [attenuator.layerResolution, attenuator.numberOfLayers];
            self.Is = cell([lightField.angularResolution, attenuator.numberOfLayers]);
            self.Js = cell(size(self.Is));
            self.Ss = cell(size(self.Is));
        end
        
        function size = get.size(self)
            size = [prod(self.lightFieldSubscriptRange), prod(self.attenuatorSubscriptRange)];
        end
        
        function P = formSparseMatrix(self)
            P = sparse([self.Is{:}], [self.Js{:}], [self.Ss{:}], self.size(1), self.size(2));
        end
        
        function submitEntries(self, cameraIndexY, cameraIndexX, ...
                                     pixelIndexOnSensorY, pixelIndexOnSensorX, ...
                                     layerIndex, ...
                                     pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                                     weightMatrix)
            
            rows = self.computeRowIndices(cameraIndexY, cameraIndexX, ...
                                          pixelIndexOnSensorY, pixelIndexOnSensorX);
            columns = self.computeColumnIndices(pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                                                layerIndex);
            
            self.Is{cameraIndexY, cameraIndexX, layerIndex} = rows';
            self.Js{cameraIndexY, cameraIndexX, layerIndex} = columns';
            self.Ss{cameraIndexY, cameraIndexX, layerIndex} = permute(weightMatrix(:), [2, 1]);
        end
        
    end
    
    methods (Access = private)
        
        function rows = computeRowIndices(self, camIndexY, ...
                                                camIndexX, ...
                                                pixelIndexMatrixY, ... 
                                                pixelIndexMatrixX)

            cameraPixelIndicesY = pixelIndexMatrixY(pixelIndexMatrixY(:, 1) ~= 0, 1); % column vector
            cameraPixelIndicesX = pixelIndexMatrixX(1, pixelIndexMatrixX(1, :) ~= 0); % row vector

            cameraPixelIndicesY = repmat(cameraPixelIndicesY, 1, numel(cameraPixelIndicesX)); 
            cameraPixelIndicesX = repmat(cameraPixelIndicesX, size(cameraPixelIndicesY, 1), 1); 

            % make copies of the image indices
            imageIndicesY = camIndexY + zeros(size(cameraPixelIndicesY));
            imageIndicesX = camIndexX + zeros(size(cameraPixelIndicesX));

            % convert the 4D subscipts to row indices all at once
            rows = sub2ind(self.lightFieldSubscriptRange, imageIndicesY(:), ...
                                                          imageIndicesX(:), ...
                                                          cameraPixelIndicesY(:), ...
                                                          cameraPixelIndicesX(:));
        end
        
        function columns = computeColumnIndices(self, pixelIndexMatrixY, ...
                                                      pixelIndexMatrixX, ...
                                                      layer)

                                            
            layerPixelIndicesY = find(pixelIndexMatrixY(:, 1)); % column vector
            layerPixelIndicesX = find(pixelIndexMatrixX(1, :)); % row vector

            layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
            layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

            layerIndices = layer + zeros(size(layerPixelIndicesY));

            % convert the subscripts to column indices
            columns = sub2ind(self.attenuatorSubscriptRange, layerPixelIndicesY(:), ...
                                                             layerPixelIndicesX(:), ...
                                                             layerIndices(:));
        end
        
    end
    
end

