classdef ReconstructionForResampledLF_V2 < AbstractReconstruction
    
    properties (SetAccess = private)
        resampledLightField;
        resamplingPlane;
    end
    
    properties
        iterations = 20;
    end
    
    methods
        
        function this = ReconstructionForResampledLF_V2(lightField, attenuator, resamplingPlane)
            
            this = this@AbstractReconstruction(lightField, attenuator);
            
            resampledLFResolution = [lightField.angularResolution, attenuator.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            newSensorPlane = SensorPlane(attenuator.planeResolution, lightField.sensorPlane.planeSize, lightField.sensorPlane.z);
            this.resamplingPlane = resamplingPlane;
            
            % Initialize empty light fields
            this.resampledLightField = LightFieldP(resampledLFData, lightField.cameraPlane, newSensorPlane);
            reconstructedLightField = LightFieldP(resampledLFData, this.lightField.cameraPlane, newSensorPlane);
            this.evaluation = ReconstructionEvaluation(this.resampledLightField, reconstructedLightField);
            
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
            
            angularResolution = this.lightField.angularResolution;
            cameraPositionMatrixY = this.lightField.cameraPlane.cameraPositionMatrixY;
            cameraPositionMatrixX = this.lightField.cameraPlane.cameraPositionMatrixX;
        
            pixelPositionsOnResamplingPlaneMatrixY = this.resamplingPlane.pixelPositionMatrixY;
            pixelPositionsOnResamplingPlaneMatrixX = this.resamplingPlane.pixelPositionMatrixX;

            [ pixelIndexOnResamplingPlaneMatrixY, pixelIndexOnResamplingPlaneMatrixX ] = ndgrid(1 : this.resamplingPlane.planeResolution(1), 1 : this.resamplingPlane.planeResolution(2));

            fprintf('Views done: \n');

            for camIndexY = 1 : angularResolution(1)
                for camIndexX = 1 : angularResolution(2)
                    
                    % get the position of the current camera on the camera plane
                    cameraPosition = [ cameraPositionMatrixY(camIndexY, camIndexX), ...
                                       cameraPositionMatrixX(camIndexY, camIndexX), ...
                                       this.lightField.cameraPlane.z ];
        
                    resamplingPlaneZ = this.resamplingPlane.z;

                    [ positionsOnSensorPlaneMatrixY, ...
                      positionsOnSensorPlaneMatrixX ] = this.projection(cameraPosition, ...
                                                                        this.lightField.sensorPlane.z, ...
                                                                        pixelPositionsOnResamplingPlaneMatrixY, ...
                                                                        pixelPositionsOnResamplingPlaneMatrixX, ...
                                                                        resamplingPlaneZ);
                    
                    [ sensorIntersectionMatrixY, ...
                      sensorIntersectionMatrixX, ...
                      validIntersections ] = this.lightField.sensorPlane.positionToPixelCoordinates(positionsOnSensorPlaneMatrixY, positionsOnSensorPlaneMatrixX);
                    
                    invalidRayIndicesForSensorY = ~sum(validIntersections, 2);
                    invalidRayIndicesForSensorX = ~sum(validIntersections, 1);
                  
                    this.resampleView(camIndexY, camIndexX, sensorIntersectionMatrixY, sensorIntersectionMatrixX);
                    
                    pixelIndexOnSensorMatrixY = pixelIndexOnResamplingPlaneMatrixY; % contains also the invalid indices
                    pixelIndexOnSensorMatrixX = pixelIndexOnResamplingPlaneMatrixX; % contains also the invalid indices

                    for layer = 1 : this.attenuator.numberOfLayers

                        % adjust distance for current layer; the coordinate origin is
                        % at the center of the layer stack
                        currentLayerZ = this.attenuator.layerPositionZ(layer);
                        
                        [ positionsOnLayerMatrixY, ...
                          positionsOnLayerMatrixX ] = this.projection(cameraPosition, ...
                                                                      currentLayerZ, ...
                                                                      pixelPositionsOnResamplingPlaneMatrixY, ...
                                                                      pixelPositionsOnResamplingPlaneMatrixX, ...
                                                                      resamplingPlaneZ);
                        
                        [ layerIntersectionMatrixY, ...
                          layerIntersectionMatrixX, ...
                          validIntersections ] = this.attenuator.positionToPixelCoordinates(positionsOnLayerMatrixY, positionsOnLayerMatrixX);
                        
                        pixelIndexOnLayerMatrixY = round(layerIntersectionMatrixY);
                        pixelIndexOnLayerMatrixX = round(layerIntersectionMatrixX);
                        
                        weightsForLayerMatrix = this.computeRayIntersectionWeights(pixelIndexOnLayerMatrixY, ...
                                                                                   pixelIndexOnLayerMatrixX, ...
                                                                                   layerIntersectionMatrixY, ...
                                                                                   layerIntersectionMatrixX);
                        
                                                                               
                                                                               
                        invalidRayIndicesForLayerY = ~sum(validIntersections, 2);
                        invalidRayIndicesForLayerX = ~sum(validIntersections, 1);
                        
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
        
        function resampleView(this, camIndexY, camIndexX, sensorIntersectionMatrixY, sensorIntersectionMatrixX)
            % Interpolating the current view of the light field
            % Interpolation in invalid query points will set the corresponding values in the light field to zero
            view = squeeze(this.lightField.lightFieldData(camIndexY, camIndexX, :, :, :));
            gridVectors = {sensorIntersectionMatrixY(:, 1), sensorIntersectionMatrixX(1, :), 1 : this.lightField.channels};
            
            % Remove arrays of singleton dimensions (2D light fields or single channel)
            indicesOfScalars = cellfun(@isscalar, gridVectors);
            grid = cell(1, nnz(~indicesOfScalars));
            [ grid{:} ] = ndgrid(gridVectors{~indicesOfScalars});
            
            this.resampledLightField.replaceView(camIndexY, camIndexX, interpn(view, grid{:}, 'linear', 0));
        end
        
    end


end

