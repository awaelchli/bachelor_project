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
        weightFunctionHandle = @(data) ones(size(data, 1), 1);
    end
    
    methods
        
        function this = Reconstruction(lightField, attenuator)
            this.lightField = lightField;
            this.attenuator = attenuator;
            
            resampledLFResolution = [lightField.angularResolution, attenuator.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            
            this.resampledLightField = LightField(resampledLFData, lightField.cameraPlane, lightField.sensorPlane);
            this.propagationMatrix = PropagationMatrix(this.resampledLightField, attenuator);
        end
        
        function computeLayers(this)
            
            this.constructPropagationMatrix();
            
            P = this.propagationMatrix.formSparseMatrix();
            
            lightFieldVector = reshape(this.resampledLightField.lightFieldData, [], this.resampledLightField.channels);

            % Convert to log light field
            lightFieldVector(lightFieldVector < 0.01) = 0.01;
            lightFieldVectorLogDomain = log(lightFieldVector);

            % Solve using SART
            tic;
            fprintf('Running optimization ...\n');

            % Optimization constraints
            ub = zeros(this.propagationMatrix.size(2), this.resampledLightField.channels); 
            lb = zeros(size(ub)) + log(0.01);
            x0 = zeros(size(ub));
            
            attenuationValuesLogDomain = sart(P, lightFieldVectorLogDomain, x0, lb, ub, this.iterations);
            attenuationValues = exp(attenuationValuesLogDomain);
            
            
            attenuationValues = permute(attenuationValues, [2, 1]);
            attenuationValues = reshape(attenuationValues, [this.attenuator.channels, this.attenuator.planeResolution, this.attenuator.numberOfLayers]);
            attenuationValues = permute(attenuationValues, [4, 2, 3, 1]);

            this.attenuator.attenuationValues = attenuationValues;
        end
        
    end
    
    methods (Access = private)
        
        function constructPropagationMatrix(this)
            
            layerResolution = this.attenuator.planeResolution;
            angularResolution = this.lightField.angularResolution;
            spatialResolution = this.lightField.spatialResolution;

            cameraPositionMatrixY = this.lightField.cameraPlane.cameraPositionMatrixY;
            cameraPositionMatrixX = this.lightField.cameraPlane.cameraPositionMatrixX;
        
            pixelPositionsOnFirstLayerMatrixY = this.attenuator.pixelPositionMatrixY;
            pixelPositionsOnFirstLayerMatrixX = this.attenuator.pixelPositionMatrixX;

            [ pixelIndexOnFirstLayerMatrixY, pixelIndexOnFirstLayerMatrixX ] = ndgrid(1 : layerResolution(1), 1 : layerResolution(2));

            fprintf('Views done: \n');

            for camIndexY = 1 : angularResolution(1)
                for camIndexX = 1 : angularResolution(2)
        
                    % get the position of the current camera on the camera plane
                    cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                                       cameraPositionMatrixX(camIndexY, camIndexX), ...
                                       this.lightField.cameraPlane.z ];
        
                    firstLayerZ = this.attenuator.layerPositionZ(1);

                    [ positionsOnSensorPlaneMatrixY, ...
                      positionsOnSensorPlaneMatrixX ] = this.projection(cameraPosition, ...
                                                                        this.lightField.sensorPlane.z, ...
                                                                        pixelPositionsOnFirstLayerMatrixY, ...
                                                                        pixelPositionsOnFirstLayerMatrixX, ...
                                                                        firstLayerZ);
        
                    [ ~, ~, ...
                      sensorIntersectionMatrixY, ...
                      sensorIntersectionMatrixX ] = computePixelIndicesOnPlane( positionsOnSensorPlaneMatrixY, ...
                                                                                positionsOnSensorPlaneMatrixX, ...
                                                                                spatialResolution, ...
                                                                                this.attenuator.planeSize, ...
                                                                                @round );
        
                    invalidRayIndicesForSensorY = sensorIntersectionMatrixY(:, 1) == 0;
                    invalidRayIndicesForSensorX = sensorIntersectionMatrixX(1, :) == 0;

                    pixelIndexOnSensorMatrixY = pixelIndexOnFirstLayerMatrixY;
                    pixelIndexOnSensorMatrixX = pixelIndexOnFirstLayerMatrixX;
                    
                    pixelIndicesOnSensorY = pixelIndexOnSensorMatrixY(~invalidRayIndicesForSensorY, 1); % column vector
                    pixelIndicesOnSensorX = pixelIndexOnSensorMatrixX(1, ~invalidRayIndicesForSensorX); % row vector

                    % Interpolating the current view of the light field
                    view = squeeze(this.lightField.lightFieldData(camIndexY, camIndexX, :, :, :));
                    gridVectors = {sensorIntersectionMatrixY(:, 1), sensorIntersectionMatrixX(1, :), 1 : this.lightField.channels};

                    % Remove arrays of singleton dimensions (2D light fields or single
                    % channel)
                    indicesOfScalars = cellfun(@isscalar, gridVectors);
                    grid = cell(1, nnz(~indicesOfScalars));
                    [ grid{:} ] = ndgrid(gridVectors{~indicesOfScalars});

                    this.resampledLightField.replaceView(camIndexY, camIndexX, interpn(view, grid{:}));
                    
                    this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                         pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                         1, ...
                                         pixelIndexOnFirstLayerMatrixY(:, 1), pixelIndexOnFirstLayerMatrixX(1, :), ...
                                         ones(layerResolution));

                    for layer = 2 : this.attenuator.numberOfLayers

                        % adjust distance for current layer; the coordinate origin is
                        % at the center of the layer stack
                        currentLayerZ = this.attenuator.layerPositionZ(layer);
                        
                        [ positionsOnLayerMatrixY, ...
                          positionsOnLayerMatrixX ] = this.projection(cameraPosition, ...
                                                                      currentLayerZ, ...
                                                                      pixelPositionsOnFirstLayerMatrixY, ...
                                                                      pixelPositionsOnFirstLayerMatrixX, ...
                                                                      firstLayerZ);



                        [ pixelIndexOnLayerMatrixY, ...
                          pixelIndexOnLayerMatrixX, ...
                          layerIntersectionMatrixY, ...
                          layerIntersectionMatrixX ] = computePixelIndicesOnPlane( positionsOnLayerMatrixY, ...
                                                                                   positionsOnLayerMatrixX, ...
                                                                                   layerResolution, ...
                                                                                   this.attenuator.planeSize, ...
                                                                                   @round );
                    
                        weightsForLayerMatrix = computeRayIntersectionWeights( pixelIndexOnLayerMatrixY, ...
                                                                               pixelIndexOnLayerMatrixX, ...
                                                                               layerIntersectionMatrixY, ...
                                                                               layerIntersectionMatrixX, ...
                                                                               this.weightFunctionHandle );

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
                    
                        this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
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
        
        function [X, Y] = projection(this, centerOfProjection, targetPlaneZ, X, Y, Z)
            
            distanceBetweenCameraPlaneAndFirstPlane = centerOfProjection(3) - Z;
            distanceBetweenCameraPlaneAndSecondPlane = centerOfProjection(3) - targetPlaneZ;
       
            % Shift positions to camera coordinate system
            X = X - centerOfProjection(1);
            Y = Y - centerOfProjection(2);

            % Project positions from first plane to the target plane
            X = X .* distanceBetweenCameraPlaneAndSecondPlane ./ distanceBetweenCameraPlaneAndFirstPlane;
            Y = Y .* distanceBetweenCameraPlaneAndSecondPlane ./ distanceBetweenCameraPlaneAndFirstPlane;

            % Shift positions back to world coordinate system
            X = X + centerOfProjection(1);
            Y = Y + centerOfProjection(2);
            
        end
        
    end


end

