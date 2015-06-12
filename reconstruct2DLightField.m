function [ lightFieldReconstruction ] = reconstruct2DLightField( P, ..., 
                                                                 lightField2D, ...
                                                                 layers1D, ...
                                                                 cameraIndices, ...
                                                                 replicationSize, ...
                                                                 displayReconstruction, ...
                                                                 displayError, ...
                                                                 outputFolder )
% Reconstruct light field from attenuation layers and evaluate error
%
% Input:  
%   
%   P:                      The propagation matrix, used to reconstruct the
%                           light field from the layers
%   lightField:             The original lightField
%   layers:                 Optimized attenuation layers
%   cameraIndices:          A matrix of the format [ Yview1, Xview1 ; 
%                                                    Yview2, Xview2 ; 
%                                                    ...             ]
%                           containing the indices of the views chosen to be
%                           reconstructed
%   displayReconstruction:  If 1, the reconstructed views get displayed on
%                           the screen and if 0, no output is shown
%   displayError:           If 1, the error gets displayed on the screen
%                           and if 0, no output is shown
%   outputFolder:           Path to the folder used to store the
%                           reconstructed images and the error images. Suppress writing to file by
%                           setting outputFolder = []

writeToFolder = ~isempty(outputFolder);
NumberOfReconstructions = size(cameraIndices, 1);
lightFieldResolution = size(lightField2D);
channels = lightFieldResolution(5);
lightFieldResolution = lightFieldResolution(1 : 4);

lightFieldRecVector = P * reshape(layers1D, size(P, 2), []);

% convert the light field vector to the 4D light field
lightFieldReconstruction = reshape(lightFieldRecVector, [lightFieldResolution channels]);
lightFieldReconstruction = exp(lightFieldReconstruction);

if( displayReconstruction )
    
    for i = 1 : NumberOfReconstructions

        currentCameraIndices = cameraIndices(i, :);
        currentReconstruction = squeeze(lightFieldReconstruction(currentCameraIndices(1), currentCameraIndices(2), :, :, :));
        currentReconstruction = reshape(currentReconstruction, [1, size(currentReconstruction)]);
        replicatedReconstruction = repmat(currentReconstruction, [replicationSize, ones(1, numel(size(currentReconstruction)) - 1)]);
        % Show and store the chosen reconstructed views
        displayTitle = ['Reconstruction of view (' num2str(currentCameraIndices(1)) ', ' num2str(currentCameraIndices(2)) ')' ];

        figure('Name', 'Light field reconstruction from layers')
        imshow(replicatedReconstruction)
        title(displayTitle);

        if( writeToFolder )
            imwrite(replicatedReconstruction, [outputFolder displayTitle '.png']);
        end

    end
end


% Compute and display the error if desired
if( displayError )
    
    for i = 1 : NumberOfReconstructions
        
        currentCameraIndices = cameraIndices(i, :);
        currentReconstruction = squeeze(lightFieldReconstruction(currentCameraIndices(1), currentCameraIndices(2), :, :, :));
        currentReconstruction = reshape(currentReconstruction, [1, size(currentReconstruction)]);
        replicatedReconstruction = repmat(currentReconstruction, [replicationSize, ones(1, numel(size(currentReconstruction)) - 1)]);
        currentView = squeeze(lightField2D(currentCameraIndices(1), currentCameraIndices(2), :, :, :));
        currentView = reshape(currentView, [1, size(currentView)]);
        replicatedView = repmat(currentView, [replicationSize, ones(1, numel(size(currentView)) - 1)]);
        
        size(replicatedView)
        size(replicatedReconstruction)
        
        [errorImage, rmse] = meanSquaredErrorImage(replicatedReconstruction, replicatedView);
        
        % Show and store the error image of the reconstruction
        displayTitle = ['MSE for view (' num2str(currentCameraIndices(1)) ', ' num2str(currentCameraIndices(2)) ')' ];
        
        figure('Name', 'Mean-Square-Error for reconstructed view')
        imshow(errorImage, [])
        title(displayTitle);
        
        fprintf(['R' displayTitle ': %f \n'], rmse);
        
        if( writeToFolder )
            imwrite(errorImage, [outputFolder displayTitle '.png']);
            
            % Write RMSE values to text file
            rmseFileID = fopen([outputFolder 'RMSE.txt'], 'wt');
            fprintf(rmseFileID, ['R' displayTitle ': %f \n'], rmse);
            fclose(rmseFileID);
        end
        
    end
    
end


end

