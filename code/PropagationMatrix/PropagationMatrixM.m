classdef PropagationMatrixM < AbstractPropagationMatrix
    
    properties (Access = private)
        I;
        J;
        S;
        currentIndex = 1;
    end
    
    methods
        
        function this = PropagationMatrixM(lightField, attenuator, numberOfNonZeros)
            this = this@AbstractPropagationMatrix(lightField, attenuator);
            % Pre-allocate memory
            this.I = zeros(1, numberOfNonZeros);
            this.J = zeros(1, numberOfNonZeros);
            this.S = zeros(1, numberOfNonZeros);
        end
        
        function P = formSparseMatrix(this)
            P = sparse(this.I, this.J, this.S, this.size(1), this.size(2));
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
            
            numberOfInsertions = numel(rows);
            this.I(this.currentIndex : this.currentIndex + numberOfInsertions - 1) = rows';
            this.J(this.currentIndex : this.currentIndex + numberOfInsertions - 1) = columns';
            this.S(this.currentIndex : this.currentIndex + numberOfInsertions - 1) = permute(weightMatrix(:), [2, 1]);
            
            this.currentIndex = this.currentIndex + numberOfInsertions;
        end
        
    end
    
end

