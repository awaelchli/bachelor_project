classdef ReconstructionEvaluation < handle
    
    properties (Constant)
        defaultOutputFolder = 'output/';
        imageOutputType = 'png';
    end
    
    properties (SetAccess = protected)
        lightField;
        attenuator;
        reconstructedLightField;
    end
    
    properties (SetAccess = private)
        reconstructionIndices;
        replicationSizes = [1, 1, 1, 1, 1];
    end
    
    properties (Dependent, SetAccess = private)
        numberOfReconstructions;
    end
    
    properties 
        outputFolder = ReconstructionEvaluation.defaultOutputFolder;
    end
    
    methods
        
        function this = ReconstructionEvaluation(lightField, attenuator, reconstructedLightField)
            this.lightField = lightField;
            this.attenuator = attenuator;
            this.reconstructedLightField = reconstructedLightField;
        end
        
        function evaluateViews(this, angularIndices)
            assert(numel(size(angularIndices)) == 2 & size(angularIndices, 2) == 2, ...
                   'evaluateViews:wrongInputDimensions', ...
                   'The input must be a N x 2 matrix containing N angular indices.');
            
            validIndices = arrayfun(@(i) this.lightField.isValidAngularIndex(angularIndices(i, :)), 1 : size(angularIndices, 1));
            this.reconstructionIndices = angularIndices(validIndices, :);
            
            if(any(~validIndices))
                ReconstructionEvaluation.warningForInvalidCameraIndices(angularIndices(~validIndices, :));
            end
        end
        
        function replicateAngularDimensionY(this, replication)
            this.replicationSizes(LightField.angularDimensions(1)) = replication;
        end
        
        function replicateAngularDimensionX(this, replication)
            this.replicationSizes(LightField.angularDimensions(2)) = replication;
        end
        
        function replicateSpatialDimensionY(this, replication)
            this.replicationSizes(LightField.spatialDimensions(1)) = replication;
        end
        
        function replicateSpatialDimensionX(this, replication)
            this.replicationSizes(LightField.spatialDimensions(2)) = replication;
        end
        
        function numberOfReconstructions = get.numberOfReconstructions(this)
            numberOfReconstructions = size(this.reconstructionIndices, 1);
        end
        
        function set.outputFolder(this, outputFolder)
            assert(ReconstructionEvaluation.folderExists(outputFolder), ...
                   'outputFolder:folderDoesNotExist', ...
                   'Invalid path: The folder "%s" does not exist.', outputFolder);
            this.outputFolder = outputFolder;
        end
        
        function clearOutputFolder(this)
        	delete([this.outputFolder '/*']);
        end
        
        function displayReconstructedViews(this)
            for i = 1 : this.numberOfReconstructions
                this.displaySingleReconstructedView(this.reconstructionIndices(i, :));
            end
        end
        
        function storeReconstructedViews(this)
            this.createOutputFolderIfNotExists();
            
            for i = 1 : this.numberOfReconstructions
                this.storeSingleReconstructedView(this.reconstructionIndices(i, :));
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
        
        function storeErrorImages(this)
            this.createOutputFolderIfNotExists();
            
            RMSEoutput = '';
            for i = 1 : this.numberOfReconstructions
                currentCameraIndex = this.reconstructionIndices(i, :);
                [~, rmse] = this.storeSingleErrorImage(currentCameraIndex);
                RMSEoutput = this.appendRMSEOutput(RMSEoutput, currentCameraIndex, rmse);
            end
            
            ReconstructionEvaluation.writeRMSEToTextFile(RMSEoutput, this.outputFolder);
        end
        
        function reconstructedView = getReplicatedReconstructedView(this, cameraIndex)
            reconstructedView = this.reconstructedLightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            reconstructedView = repmat(reconstructedView, this.replicationSizes);
            reconstructedView = squeeze(reconstructedView);
        end
        
        function displayLayers(this, layerNumbers)
            layers = this.getReplicatedAttenuationLayers(layerNumbers);
            for i = 1 : numel(layerNumbers)
                figure('Name', sprintf('Layer %i', layerNumbers(i)));
                imshow(squeeze(layers(i, :, :, :)));
            end
        end
        
        function storeLayers(this, layerNumbers)
            this.createOutputFolderIfNotExists();
            layers = this.getReplicatedAttenuationLayers(layerNumbers);
            for number = 1 : numel(layerNumbers)
                imwrite(squeeze(layers(number, :, :, :)), sprintf('%s/%i.%s', this.outputFolder, number, ReconstructionEvaluation.imageOutputType));
            end
        end
        
        function printLayers(this, layerNumbers, markerSize)
            this.createOutputFolderIfNotExists();
            layers = this.getReplicatedAttenuationLayers(1 : this.attenuator.numberOfLayers);
            layersWithMarkers = addMarkersToLayers(layers, markerSize);
            
            for i = 1 : numel(layerNumbers)
                imwrite(squeeze(layersWithMarkers(layerNumbers(i), :, :, :)), sprintf('%s/print_%i.%s', this.outputFolder, layerNumbers(i), ReconstructionEvaluation.imageOutputType));
            end
            
            filename = ['Print_Layers' sprintf('-%i', reshape(layerNumbers, 1, []))];
            printImagesToPDF(this.outputFolder, filename, layersWithMarkers(layerNumbers, :, :, :), this.attenuator.planeSize);
        end
        
    end
    
    methods (Access = private)
        
        function displaySingleReconstructedView(this, cameraIndex)
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            displayTitle = sprintf('Reconstruction of view (%i, %i)', cameraIndex);
            figure('Name', 'Light field reconstruction from attenuation layers');
            imshow(reconstructedView);
            title(displayTitle);
        end
        
        function storeSingleReconstructedView(this, cameraIndex)
            filename = sprintf('Reconstruction_of_view_(%i,%i)', cameraIndex);
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            imwrite(reconstructedView, [this.outputFolder '/' filename '.' ReconstructionEvaluation.imageOutputType]);
        end
        
        function [errorImage, rmse] = displaySingleErrorImage(this, cameraIndex)
            [errorImage, rmse] = this.getErrorForView(cameraIndex);
            displayTitle = sprintf('MSE for view (%i, %i)', cameraIndex);
            figure('Name', 'Mean-Square-Error for reconstructed view');
            imshow(errorImage, []);
            title(displayTitle);
        end
        
        function [errorImage, rmse] = storeSingleErrorImage(this, cameraIndex)
            [errorImage, rmse] = this.getErrorForView(cameraIndex);
            filename = sprintf('MSE_for_view_(%i,%i)', cameraIndex);
            imwrite(errorImage, [this.outputFolder '/' filename '.' ReconstructionEvaluation.imageOutputType]);
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
            errorImage = errorImage / max(errorImage(:));
        end
        
        function layers = getReplicatedAttenuationLayers(this, layerNumbers)
            layers = this.attenuator.getAttenuationLayers(layerNumbers);
            layers = repmat(layers, [1, this.replicationSizes([LightField.spatialDimensions, LightField.channelDimension])]);
        end
        
        function valid = outputFolderExists(this)
            valid = ReconstructionEvaluation.folderExists(this.outputFolder);
        end
        
        function createOutputFolderIfNotExists(this)
            if(~this.outputFolderExists())
                mkdir(this.outputFolder);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function warningForInvalidCameraIndices(angularIndices)
            for i = 1 : size(angularIndices, 1)
                ReconstructionEvaluation.warningForInvalidCameraIndex(angularIndices(i, :));
            end
        end
        
        function warningForInvalidCameraIndex(cameraIndex)
            warning('Skipping invalid camera index: (%i, %i)\n', cameraIndex);
        end
        
        function writeRMSEToTextFile(text, outputFolder)
            rmseFileID = fopen([outputFolder '/' 'RMSE.txt'], 'wt');
            fprintf(rmseFileID, text);
            fclose(rmseFileID);
        end
        
        function RMSEoutput = appendRMSEOutput(RMSEoutput, cameraIndex, rmse)
            RMSEoutput = sprintf('%sRMSE for view (%i, %i): %f \n', RMSEoutput, cameraIndex(1), cameraIndex(2), rmse);
        end
        
        function valid = folderExists(folder)
            valid = exist(folder, 'dir') == 7;
        end
        
    end
    
end

