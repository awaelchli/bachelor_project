classdef AbstractReconstruction < handle
    
    properties (SetAccess = protected)
        lightField;
        attenuator;
        % The propagation matrix used to solve for the attenuation values
        propagationMatrix;
        % A different propagation matrix P that can be used for reconstructing views from attenuation layers
        P;
        evaluation;
    end
    
    properties
        iterations = 20;
        weightFunctionHandle;
    end
    
    properties (Dependent, SetAccess = private)
        reconstructedLightField;
    end
    
    methods (Abstract, Access = protected)
        
        constructPropagationMatrix(this)
        
        lightField = getLightFieldForOptimization(this);
        
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
            
            if(isempty(this.P))
                this.P = this.propagationMatrix.formSparseMatrix();
            end
            
            attenuationValues = permute(this.attenuator.attenuationValues, [2, 3, 1, 4]);
            attenuationValues = reshape(attenuationValues, this.propagationMatrix.size(2), []);
            reconstructionVector = this.P * log(attenuationValues);

            % convert the light field vector to the 4D light field
            reconstructionData = reshape(reconstructionVector, [this.evaluation.reconstructedLightField.resolution, this.evaluation.reconstructedLightField.channels]);
            reconstructionData = exp(reconstructionData);
            reconstructedLF = LightField(reconstructionData);
            this.evaluation = ReconstructionEvaluation(this.evaluation.lightField, this.attenuator, reconstructedLF);
            
        end
        
        function reconstructedLightField = get.reconstructedLightField(this)
            reconstructedLightField = this.evaluation.reconstructedLightField;
        end
        
        function usePropagationMatrix(this, P)
            assert(size(P, 2) == this.propagationMatrix.size(2), ...
                   'set.P:newPmatrixHasWrongDimensions', ...
                   'The second dimension of the matrix does not match the resolution of the attenuator.');
            this.P = P;
        end
        
    end
    
    methods (Access = protected)
        
        function runOptimization(this)
            
            this.P = this.propagationMatrix.formSparseMatrix();
            lightFieldVector = this.getLightFieldForOptimization().vectorizeData();
            
            % Convert to log light field
            lightFieldVector(lightFieldVector < Attenuator.minimumTransmission) = Attenuator.minimumTransmission;
            lightFieldVectorLogDomain = log(lightFieldVector);

            % Optimization constraints
            ub = zeros(this.propagationMatrix.size(2), this.getLightFieldForOptimization().channels); 
            lb = zeros(size(ub)) + log(Attenuator.minimumTransmission);
            x0 = zeros(size(ub));
            
            % Solve using SART
            attenuationValuesLogDomain = sart(this.P, lightFieldVectorLogDomain, x0, lb, ub, this.iterations);
            
            attenuationValues = exp(attenuationValuesLogDomain);
            
            attenuationValues = permute(attenuationValues, [2, 1]);
            attenuationValues = reshape(attenuationValues, [this.attenuator.channels, this.attenuator.planeResolution, this.attenuator.numberOfLayers]);
            attenuationValues = permute(attenuationValues, [4, 2, 3, 1]);

            this.attenuator.attenuationValues = attenuationValues;
        end
        
    end
    
end

