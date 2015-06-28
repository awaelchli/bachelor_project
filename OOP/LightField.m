classdef LightField < handle
    %LIGHTFIELD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        lightFieldDimension = 4;
        angularDimensions = [1, 2];
        spatialDimensions = [3, 4];
        channelDimension = 5;
    end
    
    properties (SetAccess = private)
        lightFieldData;
        cameraPlane;
        sensorPlane;
    end
    
    properties (Dependent, SetAccess = private)
        resolution;
        angularResolution;
        spatialResolution;
        channels;
        distanceCameraToSensorPlane;
    end
    
    methods
        
        function this = LightField(lightFieldData, cameraPlane, sensorPlane)
            % TODO: write invariant to check if resolution of
            % lightFieldData corrensponds to resolution of cameraPlane and
            % sensorPlane
            this.lightFieldData = lightFieldData;
            this.cameraPlane = cameraPlane;
            this.sensorPlane = sensorPlane;
        end
        
        function resolution = get.resolution(this)
            resolution = size(this.lightFieldData);
            resolution = resolution([LightField.angularDimensions, LightField.spatialDimensions]);
        end
        
        function angularResolution = get.angularResolution(this)
            angularResolution = this.resolution(LightField.angularDimensions);
        end
        
        function spatialResolution = get.spatialResolution(this)
            spatialResolution = this.resolution(LightField.spatialDimensions);
        end
        
        function channels = get.channels(this)
            channels = size(this.lightFieldData, LightField.channelDimension);
        end
        
        function distance = get.distanceCameraToSensorPlane(this)
            distance = abs(this.cameraPlane.z - this.sensorPlane.z);
        end
        
        function replaceView(this, cameraIndexY, cameraIndexX, image)
           this.lightFieldData(cameraIndexY, cameraIndexX, : , : , :) = image; 
        end
        
    end
    
end

