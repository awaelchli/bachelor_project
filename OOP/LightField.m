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
        
        function self = LightField(lightFieldData, cameraPlane, sensorPlane)
            % TODO: write invariant to check if resolution of
            % lightFieldData corrensponds to resolution of cameraPlane and
            % sensorPlane
            self.lightFieldData = lightFieldData;
            self.cameraPlane = cameraPlane;
            self.sensorPlane = sensorPlane;
        end
        
        function resolution = get.resolution(self)
            resolution = size(self.lightFieldData);
            resolution = resolution([LightField.angularDimensions, LightField.spatialDimensions]);
        end
        
        function angularResolution = get.angularResolution(self)
            angularResolution = self.resolution(LightField.angularDimensions);
        end
        
        function spatialResolution = get.spatialResolution(self)
            spatialResolution = self.resolution(LightField.spatialDimensions);
        end
        
        function channels = get.channels(self)
            channels = size(self.lightFieldData, LightField.channelDimension);
        end
        
        function distance = get.distanceCameraToSensorPlane(self)
            distance = abs(self.cameraPlane.z - self.sensorPlane.z);
        end
        
        function replaceView(self, cameraIndexY, cameraIndexX, image)
           self.lightFieldData(cameraIndexY, cameraIndexX, : , : , :) = image; 
        end
        
    end
    
end

