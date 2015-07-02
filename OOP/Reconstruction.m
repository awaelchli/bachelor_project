classdef Reconstruction < AbstractReconstruction
    %RECONSTRUCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        resampledLightField;
    end
    
    properties
        iterations = 20;
    end
    
    methods
        
        function this = Reconstruction(lightField, attenuator)
            
            this = this@AbstractReconstruction(lightField, attenuator);
            
            resampledLFResolution = [lightField.angularResolution, attenuator.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            
            this.resampledLightField = LightField(resampledLFData, lightField.cameraPlane, lightField.sensorPlane);
            this.propagationMatrix = PropagationMatrix(this.resampledLightField, attenuator);
        end
        
    end
    
    methods (Access = protected)
        
        function runOptimization(this)
            
            P = this.propagationMatrix.formSparseMatrix();
            
            lightFieldVector = reshape(this.resampledLightField.lightFieldData, [], this.resampledLightField.channels);

            % Convert to log light field
            lightFieldVector(lightFieldVector < 0.01) = 0.01;
            lightFieldVectorLogDomain = log(lightFieldVector);

            % Optimization constraints
            ub = zeros(this.propagationMatrix.size(2), this.resampledLightField.channels); 
            lb = zeros(size(ub)) + log(0.01);
            x0 = zeros(size(ub));
            
            % Solve using SART
            attenuationValuesLogDomain = sart(P, lightFieldVectorLogDomain, x0, lb, ub, this.iterations);
            
            attenuationValues = exp(attenuationValuesLogDomain);
            
            attenuationValues = permute(attenuationValues, [2, 1]);
            attenuationValues = reshape(attenuationValues, [this.attenuator.channels, this.attenuator.planeResolution, this.attenuator.numberOfLayers]);
            attenuationValues = permute(attenuationValues, [4, 2, 3, 1]);

            this.attenuator.attenuationValues = attenuationValues;
        end
        
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
                    
                    [ sensorIntersectionMatrixY, ...
                      sensorIntersectionMatrixX ] = this.lightField.sensorPlane.positionToPixelCoordinates(positionsOnSensorPlaneMatrixY, positionsOnSensorPlaneMatrixX);
        
                    invalidRayIndicesForSensorY = sensorIntersectionMatrixY(:, 1) == 0;
                    invalidRayIndicesForSensorX = sensorIntersectionMatrixX(1, :) == 0;

                    pixelIndexOnSensorMatrixY = pixelIndexOnFirstLayerMatrixY;
                    pixelIndexOnSensorMatrixX = pixelIndexOnFirstLayerMatrixX;
                    
                    pixelIndicesOnSensorY = pixelIndexOnSensorMatrixY(~invalidRayIndicesForSensorY, ~invalidRayIndicesForSensorX); % column vector
                    pixelIndicesOnSensorX = pixelIndexOnSensorMatrixX(~invalidRayIndicesForSensorY, ~invalidRayIndicesForSensorX); % row vector

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
                                                         pixelIndexOnFirstLayerMatrixY, pixelIndexOnFirstLayerMatrixX, ...
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
                        
                        [ layerIntersectionMatrixY, ...
                          layerIntersectionMatrixX ] = this.attenuator.positionToPixelCoordinates(positionsOnLayerMatrixY, positionsOnLayerMatrixX);
                        
                        pixelIndexOnLayerMatrixY = round(layerIntersectionMatrixY);
                        pixelIndexOnLayerMatrixX = round(layerIntersectionMatrixX);
                        
                        weightsForLayerMatrix = this.computeRayIntersectionWeights(pixelIndexOnLayerMatrixY, ...
                                                                                   pixelIndexOnLayerMatrixX, ...
                                                                                   layerIntersectionMatrixY, ...
                                                                                   layerIntersectionMatrixX);
                                                                           
                        invalidRayIndicesForLayerY = pixelIndexOnLayerMatrixY(:, 1) == 0;
                        invalidRayIndicesForLayerX = pixelIndexOnLayerMatrixX(1, :) == 0;
                        
                        validRayIndicesY = ~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY);
                        validRayIndicesX = ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX);
                        
                        layerPixelIndicesY = pixelIndexOnLayerMatrixY(validRayIndicesY, validRayIndicesX); % column vector
                        layerPixelIndicesX = pixelIndexOnLayerMatrixX(validRayIndicesY, validRayIndicesX); % row vector
                        
                        pixelIndicesOnSensorY = pixelIndexOnSensorMatrixY(validRayIndicesY, validRayIndicesX); % column vector
                        pixelIndicesOnSensorX = pixelIndexOnSensorMatrixX(validRayIndicesY, validRayIndicesX); % row vector
                        
                        weightsForLayerMatrix = weightsForLayerMatrix(validRayIndicesY, validRayIndicesX);
                        
                        this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                                             pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                                             layer, ...
                                                             layerPixelIndicesY, layerPixelIndicesX, ...
                                                             weightsForLayerMatrix);
                    end
                    
                    fprintf('(%i, %i) ', camIndexY, camIndexX);
                end
                
                fprintf('\n');
            end
        end
        
        function [X, Y] = projection(~, centerOfProjection, targetPlaneZ, X, Y, Z)
            
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
        
        function weightMatrix = computeRayIntersectionWeights(this, ...
                                                              pixelIndexMatrixY, ...
                                                              pixelIndexMatrixX, ...
                                                              intersectionMatrixY, ...
                                                              intersectionMatrixX)

            % Weights are computed based on the deviation from the exact pixel location
            deviationY = intersectionMatrixY - pixelIndexMatrixY;
            deviationX = intersectionMatrixX - pixelIndexMatrixX;

            queryData = cat(3, deviationY, deviationX);
            queryData = reshape(queryData, [], 2);

            weightVector = this.weightFunctionHandle(queryData);
            weightMatrix = reshape(weightVector, size(pixelIndexMatrixY));

        end
        
    end


end

