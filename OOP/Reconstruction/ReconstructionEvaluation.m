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
            % TODO: ignore/remove invalid indices and print warning
            
            validIndices = arrayfun(@(i) this.lightField.cameraPlane.isValidCameraIndex(cameraIndices(i, :)), 1 : size(cameraIndices, 1));
            
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
        
        function displayErrorImages(this)
            RMSEoutput = '';
            for i = 1 : this.numberOfReconstructions
                currentCameraIndex = this.reconstructionIndices(i, :);
                [~, rmse] = this.displaySingleErrorImage(currentCameraIndex);
                RMSEoutput = this.appendRMSEOutput(RMSEoutput, currentCameraIndex, rmse);
            end
            % Print RMSE to console
            fprintf(RMSEoutput);
        end
        
        function storeErrorImages(this, outputFolder)
            
            if(~exist(outputFolder, 'dir'))
                ReconstructionEvaluation.warningForInvalidFolderPath(outputFolder);
                return;
            end
            RMSEoutput = '';
            for i = 1 : this.numberOfReconstructions
                currentCameraIndex = this.reconstructionIndices(i, :);
                [~, rmse] = this.storeSingleErrorImage(currentCameraIndex, outputFolder);
                RMSEoutput = this.appendRMSEOutput(RMSEoutput, currentCameraIndex, rmse);
            end
            
            ReconstructionEvaluation.writeRMSEToTextFile(RMSEoutput, outputFolder);
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
        
        function [errorImage, rmse] = displaySingleErrorImage(this, cameraIndex)
            
            if(~this.reconstructedLightField.cameraPlane.isValidCameraIndex(cameraIndex))
                ReconstructionEvaluation.warningForInvalidCameraIndex(cameraIndex);
                return;
            end
            
            [errorImage, rmse] = this.getErrorForView(cameraIndex);

            displayTitle = sprintf('MSE for view (%i, %i)', cameraIndex);
            figure('Name', 'Mean-Square-Error for reconstructed view')
            imshow(errorImage, [])
            title(displayTitle);
        end
        
        function [errorImage, rmse] = storeSingleErrorImage(this, cameraIndex, outputFolder)
            [errorImage, rmse] = this.getErrorForView(cameraIndex);
            filename = sprintf('MSE_for_view_(%i,%i)', cameraIndex);
            imwrite(errorImage, [outputFolder filename '.png']);
        end
        
        function reconstructedView = getReplicatedReconstructedView(this, cameraIndex)
            reconstructedView = this.reconstructedLightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            reconstructedView = repmat(reconstructedView, this.replicationSizes);
            reconstructedView = squeeze(reconstructedView);
        end
        
        function viewFromOriginal = getReplicatedOriginalView(this, cameraIndex)
            viewFromOriginal = this.lightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            viewFromOriginal = repmat(viewFromOriginal, this.replicationSizes);
            viewFromOriginal = squeeze(viewFromOriginal);
        end
        
        function [errorImage, rmse] = getErrorForView(this, cameraIndex)
            viewFromOriginal = this.getReplicatedOriginalView(cameraIndex);
            viewFromReconstruction = this.getReplicatedReconstructedView(cameraIndex);
            [errorImage, rmse] = meanSquaredErrorImage(viewFromReconstruction, viewFromOriginal);
        end
        
    end
    
    methods (Static, Access = private)
        
        function warningForInvalidCameraIndex(cameraIndex)
            warning('Skipping invalid camera index: (%i, %i)\n', cameraIndex);
        end
        
        function warningForInvalidFolderPath(path)
            warning('Invalid path: The folder "%s" does not exist. No files were written.', path);
        end
        
        function writeRMSEToTextFile(text, outputFolder)
            rmseFileID = fopen([outputFolder 'RMSE.txt'], 'wt');
            fprintf(rmseFileID, text);
            fclose(rmseFileID);
        end
        
        function RMSEoutput = appendRMSEOutput(RMSEoutput, cameraIndex, rmse)
            RMSEoutput = sprintf('%sRMSE for view (%i, %i): %f \n', RMSEoutput, cameraIndex(1), cameraIndex(2), rmse);
        end
        
    end
    
end

