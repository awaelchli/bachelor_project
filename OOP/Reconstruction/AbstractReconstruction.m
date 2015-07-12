classdef AbstractReconstruction < handle
    
    properties (SetAccess = protected)
        lightField;
        attenuator;
        propagationMatrix;
        evaluation;
    end
    
    properties
        weightFunctionHandle;
    end
    
    properties (Dependent, SetAccess = private)
        reconstructedLightField;
    end
    
    methods (Abstract, Access = protected)
        
        constructPropagationMatrix(this)
        
        runOptimization(this)
        
        [X, Y] = projection(this, cameraIndex, targetPlaneZ, X, Y, Z)
        
        weightMatrix = computeRayIntersectionWeights(this, pixelIndexMatrixY, pixelIndexMatrixX, intersectionMatrixY, intersectionMatrixX)
        
    end
    
    methods
        
        function this = AbstractReconstruction(lightField, attenuator)
            this.lightField = lightField;
            this.attenuator = attenuator;
            this.weightFunctionHandle = @(data) ones(size(data, 1), 1);
        end
        
        function computeAttenuationLayers(this)
            
            tic;
            fprintf('\nComputing matrix P...\n');
            this.constructPropagationMatrix();
            fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));
           
            tic;
            fprintf('Running optimization ...\n');
            this.runOptimization();
            fprintf('Optimization took %i seconds.\n', floor(toc));
            
        end
        
        function reconstructLightField(this)
            
            attenuationValues = permute(this.attenuator.attenuationValues, [2, 3, 1, 4]);
            attenuationValues = reshape(attenuationValues, this.propagationMatrix.size(2), []);
            reconstructionVector = this.propagationMatrix.formSparseMatrix * log(attenuationValues);

            % convert the light field vector to the 4D light field
            reconstructionData = reshape(reconstructionVector, [this.evaluation.reconstructedLightField.resolution, this.evaluation.reconstructedLightField.channels]);
            reconstructionData = exp(reconstructionData);
            reconstructedLF = LightField(reconstructionData);
            this.evaluation = ReconstructionEvaluation(this.evaluation.lightField, this.attenuator, reconstructedLF);
            
        end
        
        function reconstructedLightField = get.reconstructedLightField(this)
            reconstructedLightField = this.evaluation.reconstructedLightField;
        end
        
    end
    
end

