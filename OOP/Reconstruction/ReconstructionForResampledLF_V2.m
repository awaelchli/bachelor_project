classdef ReconstructionForResampledLF_V2 < AbstractReconstruction
    
    properties (Constant)
        interpolationMethod = 'linear';
    end
    
    properties (SetAccess = private)
        resampledLightField;
        resamplingPlane;
    end
    
    methods
        
        function this = ReconstructionForResampledLF_V2(lightField, attenuator, resamplingPlane)
            this = this@AbstractReconstruction(lightField, attenuator);
            
            resampledLFResolution = [lightField.angularResolution, resamplingPlane.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            newSensorPlane = SensorPlane(resamplingPlane.planeResolution, lightField.sensorPlane.planeSize, lightField.sensorPlane.z);
            this.resamplingPlane = resamplingPlane;
            
            % Initialize empty light fields
            this.resampledLightField = LightFieldP(resampledLFData, lightField.cameraPlane, newSensorPlane);
            reconstructedLightField = LightFieldP(resampledLFData, this.lightField.cameraPlane, newSensorPlane);
            this.evaluation = ReconstructionEvaluation(this.resampledLightField, attenuator, reconstructedLightField);
            
            this.propagationMatrix = PropagationMatrix(this.resampledLightField, attenuator);
        end
        
    end
    
    methods (Access = protected)
        
        function lightField = getLightFieldForOptimization(this)
            % Use the resampled light field for optimization instead of the input light field
            lightField = this.resampledLightField;
        end
        
        function constructPropagationMatrix(this)
            
            pixelPositionsOnResamplingPlaneMatrixY = this.resamplingPlane.pixelPositionMatrixY;
            pixelPositionsOnResamplingPlaneMatrixX = this.resamplingPlane.pixelPositionMatrixX;
            resamplingPlaneZ = this.resamplingPlane.z;

            [ pixelIndexOnResamplingPlaneMatrixY, pixelIndexOnResamplingPlaneMatrixX ] = ndgrid(1 : this.resamplingPlane.planeResolution(1), 1 : this.resamplingPlane.planeResolution(2));

            for camIndexY = 1 : this.lightField.angularResolution(1)
                for camIndexX = 1 : this.lightField.angularResolution(2)
                    
                    [ positionsOnSensorPlaneMatrixY, ...
                      positionsOnSensorPlaneMatrixX ] = this.projection([camIndexY, camIndexX], ...
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
                          positionsOnLayerMatrixX ] = this.projection([camIndexY, camIndexX], ...
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
                    
                    this.progressUpdateForMatrixConstruction(camIndexY, camIndexX);
                end
            end
        end
        
        function [X, Y] = projection(this, cameraIndex, targetPlaneZ, X, Y, Z)
            
            % get the position of the current camera on the camera plane
            centerOfProjection = [this.lightField.cameraPlane.cameraPositionMatrixY(cameraIndex(1), cameraIndex(2)), ...
                                  this.lightField.cameraPlane.cameraPositionMatrixX(cameraIndex(1), cameraIndex(2)), ...
                                  this.lightField.cameraPlane.z];
            
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
            
            this.resampledLightField.replaceView(camIndexY, camIndexX, interpn(view, grid{:}, ReconstructionForResampledLF_V2.interpolationMethod, 0));
        end
        
    end


end

