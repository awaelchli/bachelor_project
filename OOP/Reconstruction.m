classdef Reconstruction < handle
    %RECONSTRUCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        lightField;
        attenuator;
        resampledLightField;
        propagationMatrix;
    end
    
    properties
        iterations = 20;
    end
    
    methods
        
        function self = Reconstruction(lightField, attenuator)
            self.lightField = lightField;
            self.attenuator = attenuator;
            
            resampledLFResolution = [lightField.angularResolution, attenuator.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            
            self.resampledLightField = LightField(resampledLFData, lightField.cameraPlane, lightField.sensorPlane);
            self.propagationMatrix = PropagationMatrix(self.resampledLightField, attenuator);
        end
        
        function computeLayers(self)
            
            weightFunctionHandle = @(data) ones(size(data, 1), 1);
            
            self.constructPropagationMatrix(weightFunctionHandle);
            P = self.propagationMatrix.formSparseMatrix();
            
            lightFieldVector = reshape(self.resampledLightField.lightFieldData, [], self.resampledLightField.channels);

            % Convert to log light field
            lightFieldVectorLogDomain = lightFieldVector;
            lightFieldVectorLogDomain(lightFieldVectorLogDomain < 0.01) = 0.01;
            lightFieldVectorLogDomain = log(lightFieldVectorLogDomain);

            % Solve using SART
            tic;
            fprintf('Running optimization ...\n');

            % Optimization constraints
            ub = zeros(self.propagationMatrix.size(2), self.resampledLightField.channels); 
            lb = zeros(size(ub)) + log(0.01);
            x0 = zeros(size(ub));
            
            self.attenuator.attenuationValues = sart(P, lightFieldVectorLogDomain, x0, lb, ub, self.iterations);
        end
        
    end
    
    methods (Access = private)
        
        function constructPropagationMatrix(self, weightFunctionHandle)
            
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
                    
                    % TODO: use invalidRayIndicesForSensor directly!
                    pixelIndicesOnSensorY = pixelIndexOnSensorMatrixY(pixelIndexOnSensorMatrixY(:, 1) ~= 0, 1); % column vector
                    pixelIndicesOnSensorX = pixelIndexOnSensorMatrixX(1, pixelIndexOnSensorMatrixX(1, :) ~= 0); % row vector

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
                    
                    self.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                         pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                         1, ...
                                         pixelIndexOnFirstLayerMatrixY(:, 1), pixelIndexOnFirstLayerMatrixX(1, :), ...
                                         ones(layerResolution)); % TODO: check if layerResolution correct

                    for layer = 2 : self.attenuator.numberOfLayers

                        % adjust distance for current layer; the coordinate origin is
                        % at the center of the layer stack
                        currentLayerZ = self.attenuator.layerPositionZ(layer);

                        [ positionsOnLayerMatrixY, ...
                          positionsOnLayerMatrixX ] = computeRayIntersectionsOnPlane( cameraPosition, ...
                                                                                      self.lightField.cameraPlane.z, ...
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
                                                                                   self.attenuator.planeSize, ...
                                                                                   @round );
                    
                        weightsForLayerMatrix = computeRayIntersectionWeights( pixelIndexOnLayerMatrixY, ...
                                                                               pixelIndexOnLayerMatrixX, ...
                                                                               layerIntersectionMatrixY, ...
                                                                               layerIntersectionMatrixX, ...
                                                                               weightFunctionHandle );

                        pixelIndexOnLayerMatrixY(invalidRayIndicesForSensorY, :) = 0;
                        pixelIndexOnLayerMatrixX(:, invalidRayIndicesForSensorX) = 0;

                        layerPixelIndicesY = pixelIndexOnLayerMatrixY(pixelIndexOnLayerMatrixY(:, 1) ~= 0, 1); % column vector
                        layerPixelIndicesX = pixelIndexOnLayerMatrixX(1, pixelIndexOnLayerMatrixX(1, :) ~= 0); % row vector

                        invalidRayIndicesForLayerY = pixelIndexOnLayerMatrixY(:, 1) == 0;
                        invalidRayIndicesForLayerX = pixelIndexOnLayerMatrixX(1, :) == 0;

                        pixelIndexOnSensorMatrixY(invalidRayIndicesForLayerY, :) = 0;
                        pixelIndexOnSensorMatrixX(:, invalidRayIndicesForLayerX) = 0;

                        pixelIndicesOnSensorY = pixelIndexOnSensorMatrixY(pixelIndexOnSensorMatrixY(:, 1) ~= 0, 1); % column vector
                        pixelIndicesOnSensorX = pixelIndexOnSensorMatrixX(1, pixelIndexOnSensorMatrixX(1, :) ~= 0); % row vector

                        weights = weightsForLayerMatrix;
                        weights = weights(~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY), :);
                        weights = weights(: , ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX));
                    
                        self.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                             pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                             layer, ...
                                             layerPixelIndicesY, layerPixelIndicesX, ...
                                             weights);
                    end
                    
                    fprintf('(%i, %i) ', camIndexY, camIndexX);
                end
                
                fprintf('\n');
            end
        end
        
    end


end

