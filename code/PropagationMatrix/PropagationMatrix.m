classdef PropagationMatrix < AbstractPropagationMatrix
    
    properties (Access = private)
        Is;
        Js;
        Ss;
    end
    
    methods
        
        function this = PropagationMatrix(lightField, attenuator)
            this = this@AbstractPropagationMatrix(lightField, attenuator);
            this.Is = cell([lightField.angularResolution, attenuator.numberOfLayers]);
            this.Js = cell(size(this.Is));
            this.Ss = cell(size(this.Is));
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
        
        function clear(this)
            this.Is = cell(size(this.Is));
            this.Js = cell(size(this.Js));
            this.Ss = cell(size(this.Ss));
        end
        
    end
    
end

