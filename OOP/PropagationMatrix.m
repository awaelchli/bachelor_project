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
        
        function this = PropagationMatrix(lightField, attenuator)
            this.lightFieldSubscriptRange = lightField.resolution;
            this.attenuatorSubscriptRange = [attenuator.planeResolution, attenuator.numberOfLayers];
            this.Is = cell([lightField.angularResolution, attenuator.numberOfLayers]);
            this.Js = cell(size(this.Is));
            this.Ss = cell(size(this.Is));
        end
        
        function size = get.size(this)
            size = [prod(this.lightFieldSubscriptRange), prod(this.attenuatorSubscriptRange)];
        end
        
        function P = formSparseMatrix(this)
            P = sparse([this.Is{:}], [this.Js{:}], [this.Ss{:}], this.size(1), this.size(2));
        end
        
        function submitEntries(this, cameraIndexY, cameraIndexX, ...
                                     pixelIndexOnSensorY, pixelIndexOnSensorX, ...
                                     layerIndex, ...
                                     pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                                     weightMatrix)
            
            rows = this.computeRowIndices(cameraIndexY, cameraIndexX, ...
                                          pixelIndexOnSensorY, pixelIndexOnSensorX);
            columns = this.computeColumnIndices(pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                                                layerIndex);
            
            this.Is{cameraIndexY, cameraIndexX, layerIndex} = rows';
            this.Js{cameraIndexY, cameraIndexX, layerIndex} = columns';
            this.Ss{cameraIndexY, cameraIndexX, layerIndex} = permute(weightMatrix(:), [2, 1]);
        end
        
    end
    
    methods (Access = private)
        
        function rows = computeRowIndices(this, camIndexY, ...
                                                camIndexX, ...
                                                cameraPixelIndicesY, ...
                                                cameraPixelIndicesX)

%             cameraPixelIndicesY = repmat(cameraPixelIndicesY, 1, numel(cameraPixelIndicesX)); 
%             cameraPixelIndicesX = repmat(cameraPixelIndicesX, size(cameraPixelIndicesY, 1), 1); 

            imageIndicesY = camIndexY + zeros(size(cameraPixelIndicesY));
            imageIndicesX = camIndexX + zeros(size(cameraPixelIndicesX));

            rows = sub2ind(this.lightFieldSubscriptRange, imageIndicesY(:), ...
                                                          imageIndicesX(:), ...
                                                          cameraPixelIndicesY(:), ...
                                                          cameraPixelIndicesX(:));
        end
        
        function columns = computeColumnIndices(this, layerPixelIndicesY, ...
                                                      layerPixelIndicesX, ...
                                                      layer)
                                            
%             layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
%             layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

            layerIndices = layer + zeros(size(layerPixelIndicesY));

            columns = sub2ind(this.attenuatorSubscriptRange, layerPixelIndicesY(:), ...
                                                             layerPixelIndicesX(:), ...
                                                             layerIndices(:));
        end
        
    end
    
end

