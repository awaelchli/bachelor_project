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
    
    methods (Abstract, Access = protected)
        
        constructPropagationMatrix(this)
        
        runOptimization(this)
        
        [X, Y] = projection(this, centerOfProjection, targetPlaneZ, X, Y, Z)
        
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
        
        function storeReconstructedViews(this, cameraIndices, outputFolder)
            
            if(~exist(outputFolder, 'dir'))
                AbstractReconstruction.warningForInvalidFolderPath(outputFolder);
                return;
            end
            
            NumberOfViews = size(cameraIndices, 1);
            for i = 1 : NumberOfViews
                this.storeSingleReconstructedView(cameraIndices(i, :), outputFolder);
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function displaySingleReconstructedView(this, cameraIndex)
            
            if(~this.reconstructedLightField.cameraPlane.isValidCameraIndex(cameraIndex))
                AbstractReconstruction.warningForInvalidCameraIndex(cameraIndex);
                return;
            end
    
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            
            displayTitle = sprintf('Reconstruction of view (%i, %i)', cameraIndex);
            figure('Name', 'Light field reconstruction from attenuation layers')
            imshow(reconstructedView)
            title(displayTitle);
        end
        
        function storeSingleReconstructedView(this, cameraIndex, outputFolder)
            
            if(~this.reconstructedLightField.cameraPlane.isValidCameraIndex(cameraIndex))
                AbstractReconstruction.warningForInvalidCameraIndex(cameraIndex);
                return;
            end
            
            filename = sprintf('Reconstruction_of_view_(%i,%i)', cameraIndex);
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            imwrite(reconstructedView, [outputFolder filename '.png']);
        end
        
        function reconstructedView = getReplicatedReconstructedView(this, cameraIndex)
            % TODO: Make replicationSizes accessible from outside
            replicationSizes = [1, 1, 1, 1, 1];
            
            reconstructedView = this.reconstructedLightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            reconstructedView = repmat(reconstructedView, replicationSizes);
            reconstructedView = squeeze(reconstructedView);
        end
        
    end
    
    methods (Static, Access = private)
        
        function warningForInvalidCameraIndex(cameraIndex)
            warning('Invalid camera indices: (%i, %i)\n', cameraIndex);
        end
        
        function warningForInvalidFolderPath(path)
            warning('Invalid path: The folder "%s" does not exist. No files were written.', path);
        end
        
    end


end

