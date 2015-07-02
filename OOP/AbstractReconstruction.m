classdef AbstractReconstruction < handle
    
    properties (SetAccess = protected)
        lightField;
        attenuator;
        propagationMatrix;
    end
    
    properties
        weightFunctionHandle;
    end
    
    methods
        
        function this = AbstractReconstruction(lightField, attenuator)
            this.lightField = lightField;
            this.attenuator = attenuator;
            this.propagationMatrix = PropagationMatrix(lightField, attenuator);
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
        
    end
    
    methods (Abstract, Access = protected)
        
        constructPropagationMatrix(this)
        
        runOptimization(this)
        
        [X, Y] = projection(this, centerOfProjection, targetPlaneZ, X, Y, Z)
        
        weightMatrix = computeRayIntersectionWeights(this, ...
                                                     pixelIndexMatrixY, ...
                                                     pixelIndexMatrixX, ...
                                                     intersectionMatrixY, ...
                                                     intersectionMatrixX)
        
    end


end

