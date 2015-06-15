function [ lightFieldReconstruction ] = reconstructLightField( P, ..., 
                                                               lightField, ...
                                                               layers, ...
                                                               cameraIndices, ...
                                                               replicationSizes, ...
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
%   replicationSizes:       A vector containing the number of replications of the reconstructed views in each dimension.
%                           It can be used to replicate the 1D views of 2D lightfields along the second dimension to
%                           make them better visible.
%   displayReconstruction:  If 1, the reconstructed views get displayed on
%                           the screen and if 0, no output is shown
%   displayError:           If 1, the error gets displayed on the screen
%                           and if 0, no output is shown
%   outputFolder:           Path to the folder used to store the
%                           reconstructed images and the error images. Suppress writing to file by
%                           setting outputFolder = []

writeToFolder = ~isempty(outputFolder);
NumberOfReconstructions = size(cameraIndices, 1);
lightFieldResolution = size(lightField);
channels = lightFieldResolution(5);
lightFieldResolution = lightFieldResolution(1 : 4);

lightFieldRecVector = P * reshape(layers, size(P, 2), []);

% convert the light field vector to the 4D light field
lightFieldReconstruction = reshape(lightFieldRecVector, [lightFieldResolution channels]);
lightFieldReconstruction = exp(lightFieldReconstruction);


for i = 1 : NumberOfReconstructions
    
    currentCameraIndices = cameraIndices(i, :);
    
    if(any(currentCameraIndices > lightFieldResolution([1, 2])) || ...
       any(currentCameraIndices < [1, 1]) || ...
       any(mod(currentCameraIndices, 1)))
   
        % Skip invalid indices
        fprintf('Skipping reconstruction for invalid camera indices: (%i, %i)\n', currentCameraIndices);
        continue;
    end
    
    currentReconstruction = lightFieldReconstruction(currentCameraIndices(1), currentCameraIndices(2), :, :, :);
    currentReconstruction = repmat(currentReconstruction, replicationSizes);
    currentReconstruction = squeeze(currentReconstruction);
        
    % Show and store the chosen reconstructed views
    if( displayReconstruction )
        
        displayTitle = ['Reconstruction of view (' num2str(currentCameraIndices(1)) ', ' num2str(currentCameraIndices(2)) ')' ];

        figure('Name', 'Light field reconstruction from layers')
        imshow(currentReconstruction)
        title(displayTitle);

        if( writeToFolder )
            imwrite(currentReconstruction, [outputFolder displayTitle '.png']);
        end
    end
    
    % Compute and display the error if desired
    if( displayError )
        
        currentView = lightField(currentCameraIndices(1), currentCameraIndices(2), :, :, :);
        currentView = repmat(currentView, replicationSizes);
        currentView = squeeze(currentView);
        
        [errorImage, rmse] = meanSquaredErrorImage(currentReconstruction, currentView);
        
        % Show and store the error image of the reconstruction
        displayTitle = ['MSE for view (' num2str(currentCameraIndices(1)) ', ' num2str(currentCameraIndices(2)) ')' ];
        
        figure('Name', 'Mean-Square-Error for reconstructed view')
        imshow(errorImage, [])
        title(displayTitle);
        
        fprintf(['R' displayTitle ': %f \n'], rmse);
        
        if( writeToFolder )
            imwrite(errorImage, [outputFolder displayTitle '.png']);
            
            % Write RMSE values to text file
            writeRMSEToTextFile(['R' displayTitle ': %f \n'], rmse, outputFolder);
        end
    end
    
end

end

function writeRMSEToTextFile(text, rmse, outputFolder)
    rmseFileID = fopen([outputFolder 'RMSE.txt'], 'wt');
    fprintf(rmseFileID, text, rmse);
    fclose(rmseFileID);
end

