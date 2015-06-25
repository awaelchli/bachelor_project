classdef Reconstruction
    %RECONSTRUCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        lightField;
        attenuator;
        resampledLightField;
        P;
    end
    
    methods
        
        function self = Reconstruction(lightField, attenuator)
            self.lightField = lightField;
            self.attenuator = attenuator;
            
            resampledLFResolution = [lightField.angularResolution, attenuator.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            
            self.resampledLightField = LightField(resampledLFData, lightField.cameraPlane, lightField.sensorPlane);
            self.P = PropagationMatrix(self.resampledLightField, attenuator);
        end
        
        function constructPropagationMatrix(self)
            
            layerResolution = self.attenuator.planeResolution;
            angularResolution = self.lightField.angularResolution;
            spatialResolution = self.lightField.spatialResolution;

            cameraPositionMatrixY = self.lightField.cameraPlane.cameraPositionMatrixY;
            cameraPositionMatrixX = self.lightField.cameraPlane.cameraPositionMatrixX;
        
            pixelPositionsOnFirstLayerMatrixY = self.attenuator.pixelPositionMatrixY;
            pixelPositionsOnFirstLayerMatrixX = self.attenuator.pixelPositionMatrixX;

            [ pixelIndexOnFirstLayerMatrixY, pixelIndexOnFirstLayerMatrixX ] = ndgrid(1 : layerResolution(1), 1 : layerResolution(2));

            fprintf('Views done: \n');

            for camIndexY = 1 : angularResolution(1)
                for camIndexX = 1 : angularResolution(2)
        
                    % get the position of the current camera on the camera plane
                    cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                                       cameraPositionMatrixX(camIndexY, camIndexX) ];
        
                    firstLayerZ = self.attenuator.layerPositionZ(1);
        
                    [ positionsOnSensorPlaneMatrixY, ...
                      positionsOnSensorPlaneMatrixX ] = computeRayIntersectionsOnPlane( cameraPosition, ...
                                                                                        self.lightField.cameraPlane.z, ...
                                                                                        firstLayerZ, ...
                                                                                        self.lightField.sensorPlane.z, ...
                                                                                        pixelPositionsOnFirstLayerMatrixY, ...
                                                                                        pixelPositionsOnFirstLayerMatrixX );
        
                    [ ~, ~, ...
                      sensorIntersectionMatrixY, ...
                      sensorIntersectionMatrixX ] = computePixelIndicesOnPlane( positionsOnSensorPlaneMatrixY, ...
                                                                                positionsOnSensorPlaneMatrixX, ...
                                                                                spatialResolution, ...
                                                                                self.attenuator.planeSize, ...
                                                                                @round );
        
                    invalidRayIndicesForSensorY = sensorIntersectionMatrixY(:, 1) == 0;
                    invalidRayIndicesForSensorX = sensorIntersectionMatrixX(1, :) == 0;

                    pixelIndexOnSensorMatrixY = pixelIndexOnFirstLayerMatrixY;
                    pixelIndexOnSensorMatrixX = pixelIndexOnFirstLayerMatrixX;

                    pixelIndexOnSensorMatrixY(invalidRayIndicesForSensorY, :) = 0;
                    pixelIndexOnSensorMatrixX(:, invalidRayIndicesForSensorX) = 0;

                    % Interpolating the current view of the light field
                    view = squeeze(self.lightField.lightFieldData(camIndexY, camIndexX, :, :, :));
                    gridVectors = {sensorIntersectionMatrixY(:, 1), sensorIntersectionMatrixX(1, :), 1 : self.lightField.channels};

                    % Remove arrays of singleton dimensions (2D light fields or single
                    % channel)
                    indicesOfScalars = cellfun(@isscalar, gridVectors);
                    grid = cell(1, nnz(~indicesOfScalars));
                    [ grid{:} ] = ndgrid(gridVectors{~indicesOfScalars});

                    % TODO: write the method "replaceView"
                    self.resampledLightField.replaceView(camIndexY, camIndexX, interpn(view, grid{:}));
                    
                    self.P.submitEntries(camIndexY, camIndexX, ...
                                         pixelIndexOnSensorMatrixY, pixelIndexOnSensorMatrixX, ...
                                         1, ...
                                         pixelIndexOnFirstLayerMatrixY, pixelIndexOnFirstLayerMatrixX, ...
                                         ones(layerResolution)); % TODO: check if layerResolution correct

                    for layer = 2 : self.attenuator.numberOfLayers

                    % adjust distance for current layer; the coordinate origin is
                    % at the center of the layer stack
                    currentLayerZ = layerPositionsZ(layer);

                    [ positionsOnLayerMatrixY, ...
                      positionsOnLayerMatrixX ] = computeRayIntersectionsOnPlane( cameraPosition, ...
                                                                                  cameraPlaneDistance, ...
                                                                                  firstLayerZ, ...
                                                                                  currentLayerZ, ...
                                                                                  pixelPositionsOnFirstLayerMatrixY, ...
                                                                                  pixelPositionsOnFirstLayerMatrixX );



                    [ pixelIndexOnLayerMatrixY, ...
                      pixelIndexOnLayerMatrixX, ...
                      layerIntersectionMatrixY, ...
                      layerIntersectionMatrixX ] = computePixelIndicesOnPlane( positionsOnLayerMatrixY, ...
                                                                               positionsOnLayerMatrixX, ...
                                                                               layerResolution, ...
                                                                               layerSize, ...
                                                                               @round );
                                                                           
%                     tempPixelIndexOnLayerMatrixY = min(pixelIndexOnLayerMatrixY + sy, layerResolution(1));
%                     tempPixelIndexOnLayerMatrixY = max(tempPixelIndexOnLayerMatrixY, 0);
%                     tempPixelIndexOnLayerMatrixX = min(pixelIndexOnLayerMatrixX + sx, layerResolution(2));
%                     tempPixelIndexOnLayerMatrixX = max(tempPixelIndexOnLayerMatrixX, 0);

%                     weightsForLayerMatrix = computeRayIntersectionWeights( tempPixelIndexOnLayerMatrixY, ...
%                                                                            tempPixelIndexOnLayerMatrixX, ...
%                                                                            layerIntersectionMatrixY, ...
%                                                                            layerIntersectionMatrixX, ...
%                                                                            weightFunctionHandle );
% 
%                     tempPixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
%                     tempPixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;
                    
                    weightsForLayerMatrix = computeRayIntersectionWeights( pixelIndexOnLayerMatrixY, ...
                                                                           pixelIndexOnLayerMatrixX, ...
                                                                           layerIntersectionMatrixY, ...
                                                                           layerIntersectionMatrixX, ...
                                                                           weightFunctionHandle );

                    pixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
                    pixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;

%                     layerPixelIndicesY = tempPixelIndexOnLayerMatrixY(tempPixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
%                     layerPixelIndicesX = tempPixelIndexOnLayerMatrixX(1, tempPixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

                    layerPixelIndicesY = pixelIndexOnLayerMatrixY(pixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
                    layerPixelIndicesX = pixelIndexOnLayerMatrixX(1, pixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

                    layerPixelIndicesY = repmat(layerPixelIndicesY, 1, numel(layerPixelIndicesX)); 
                    layerPixelIndicesX = repmat(layerPixelIndicesX, size(layerPixelIndicesY, 1), 1); 

                    layerIndices = layer + zeros(size(layerPixelIndicesY));

                    % convert the subscripts to column indices
                    columns = sub2ind([layerResolution NumberOfLayers], layerPixelIndicesY(:), ...
                                                                        layerPixelIndicesX(:), ...
                                                                        layerIndices(:));

%                     invalidRayIndicesForLayerY = tempPixelIndexOnLayerMatrixY(:, 1) == 0;
%                     invalidRayIndicesForLayerX = tempPixelIndexOnLayerMatrixX(1, :) == 0;

                    invalidRayIndicesForLayerY = pixelIndexOnLayerMatrixY(:, 1) == 0;
                    invalidRayIndicesForLayerX = pixelIndexOnLayerMatrixX(1, :) == 0;

%                     tempPixelIndexOnSensorMatrixY = pixelIndexOnSensorMatrixY;
%                     tempPixelIndexOnSensorMatrixX = pixelIndexOnSensorMatrixX;
% 
%                     tempPixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
%                     tempPixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;
% 
%                     rows = computeRowIndicesForP(camIndexY, ...
%                                                  camIndexX, ...
%                                                  tempPixelIndexOnSensorMatrixY, ... 
%                                                  tempPixelIndexOnSensorMatrixX, ...
%                                                  resampledLFResolution);

                    pixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
                    pixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;

                    rows = computeRowIndicesForP(camIndexY, ...
                                                 camIndexX, ...
                                                 pixelIndexOnSensorMatrixY, ... 
                                                 pixelIndexOnSensorMatrixX, ...
                                                 resampledLFResolution);

                    weights = weightsForLayerMatrix;
                    weights = weights(~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY), :);
                    weights = weights(: , ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX));
                    
%                     boxIndexY = sy + boxRadius + 1;
%                     boxIndexX = sx + boxRadius + 1;
                    
%                     Is{camIndexY, camIndexX, layer, boxIndexY, boxIndexX} = rows;
%                     Js{camIndexY, camIndexX, layer, boxIndexY, boxIndexX} = columns;
%                     Ss{camIndexY, camIndexX, layer, boxIndexY, boxIndexX} = weights(:);
%                     numel(rows) == numel(weights)
                    Is{camIndexY, camIndexX, layer} = rows';
                    Js{camIndexY, camIndexX, layer} = columns';
                    Ss{camIndexY, camIndexX, layer} = permute(weights(:), [2, 1]);
%                     Ss{camIndexY, camIndexX, layer} = rand(size(rows));
                end
%             end
%         end
        
        fprintf('(%i, %i) ', camIndexY, camIndexX);
    end
    fprintf('\n');
end
% 
% Is
% Js
% Ss

P = sparse([Is{:}], [Js{:}], [Ss{:}], prod(resampledLFResolution), prod([ NumberOfLayers layerResolution ]));

end
        end
    end
    
end

