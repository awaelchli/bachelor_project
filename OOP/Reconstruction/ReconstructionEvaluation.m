classdef ReconstructionEvaluation < handle
    
    properties (SetAccess = protected)
        lightField;
        reconstructedLightField;
    end
    
    properties (SetAccess = private)
        reconstructionIndices;
        replicationSizes = [1, 1, 1, 1, 1];
    end
    
    properties (Dependent, SetAccess = private)
        numberOfReconstructions;
    end
    
    methods
        
        function this = ReconstructionEvaluation(lightField, reconstructedLightField)
            this.lightField = lightField;
            this.reconstructedLightField = reconstructedLightField;
        end
        
        function evaluateViews(this, cameraIndices)
            % TODO: check dimensions
            this.reconstructionIndices = cameraIndices;
        end
        
        function replicate(this, replicationSizes)
            % TODO: implement
        end
        
        function numberOfReconstructions = get.numberOfReconstructions(this)
            numberOfReconstructions = size(this.reconstructionIndices, 1);
        end
        
        function displayReconstructedViews(this)
            for i = 1 : this.numberOfReconstructions
                this.displaySingleReconstructedView(this.reconstructionIndices(i, :));
            end
        end
        
        function storeReconstructedViews(this, outputFolder)
            
            if(~exist(outputFolder, 'dir'))
                ReconstructionEvaluation.warningForInvalidFolderPath(outputFolder);
                return;
            end
            
            for i = 1 : this.numberOfReconstructions
                this.storeSingleReconstructedView(this.reconstructionIndices(i, :), outputFolder);
            end
        end
        
        function displayErrorImage(this)
        end
        
    end
    
    methods (Access = private)
        
        function displaySingleReconstructedView(this, cameraIndex)
            
            if(~this.reconstructedLightField.cameraPlane.isValidCameraIndex(cameraIndex))
                ReconstructionEvaluation.warningForInvalidCameraIndex(cameraIndex);
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
                ReconstructionEvaluation.warningForInvalidCameraIndex(cameraIndex);
                return;
            end
            
            filename = sprintf('Reconstruction_of_view_(%i,%i)', cameraIndex);
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            imwrite(reconstructedView, [outputFolder filename '.png']);
        end
        
        function reconstructedView = getReplicatedReconstructedView(this, cameraIndex)
            reconstructedView = this.reconstructedLightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            reconstructedView = repmat(reconstructedView, this.replicationSizes);
            reconstructedView = squeeze(reconstructedView);
        end
        
    end
    
    methods (Static, Access = private)
        
        function warningForInvalidCameraIndex(cameraIndex)
            warning('Skipping invalid camera index: (%i, %i)\n', cameraIndex);
        end
        
        function warningForInvalidFolderPath(path)
            warning('Invalid path: The folder "%s" does not exist. No files were written.', path);
        end
        
    end
    
end

