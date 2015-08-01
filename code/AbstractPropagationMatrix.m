classdef AbstractPropagationMatrix < handle
    
    properties (SetAccess = private)
        lightFieldSubscriptRange;
        attenuatorSubscriptRange;
    end
    
    properties (Dependent, SetAccess = private)
        size;
    end
    
    methods (Abstract)
        
        P = formSparseMatrix(this)
        
        submitEntries(this, cameraIndexY, cameraIndexX, ...
                            pixelIndexOnSensorY, pixelIndexOnSensorX, ...
                            layerIndex, ...
                            pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                            weightMatrix)
            
    end
    
    methods
        
        function this = AbstractPropagationMatrix(lightField, attenuator)
            this.lightFieldSubscriptRange = lightField.resolution;
            this.attenuatorSubscriptRange = [attenuator.planeResolution, attenuator.numberOfLayers];
        end
        
        function size = get.size(this)
            size = [prod(this.lightFieldSubscriptRange), prod(this.attenuatorSubscriptRange)];
        end
        
    end
    
    methods (Access = protected)
        
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

