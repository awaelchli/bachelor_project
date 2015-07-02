classdef AbstractReconstruction < handle
    
    properties (SetAccess = protected)
        lightField;
        reconstructedLightField;
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
            reconstructionData = reshape(reconstructionVector, [this.reconstructedLightField.resolution, this.reconstructedLightField.channels]);
            reconstructionData = exp(reconstructionData);
            this.reconstructedLightField = LightField(reconstructionData, this.reconstructedLightField.cameraPlane, this.reconstructedLightField.sensorPlane);
            
        end
        
        function displayReconstructedViews(this, cameraIndices)
            
            NumberOfViews = size(cameraIndices, 1);
            for i = 1 : NumberOfViews
                this.displaySingleReconstructedView(cameraIndices(i, :));
            end
            
        end
        
        function displaySingleReconstructedView(this, cameraIndex)
            
            % TODO: Make replicationSizes accessible from outside
            replicationSizes = [1, 1, 1, 1, 1];
            
            if(any(cameraIndex > this.reconstructedLightField.angularResolution) || ...
               any(cameraIndex < [1, 1]) || ...
               any(mod(cameraIndex, 1)))
   
                error('Invalid camera indices: (%i, %i)\n', cameraIndex);
            end
    
            reconstructedView = this.reconstructedLightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            reconstructedView = repmat(reconstructedView, replicationSizes);
            reconstructedView = squeeze(reconstructedView);
            
            displayTitle = sprintf('Reconstruction of view (%i, %i)', cameraIndex);
            figure('Name', 'Light field reconstruction from layers')
            imshow(reconstructedView)
            title(displayTitle);
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

