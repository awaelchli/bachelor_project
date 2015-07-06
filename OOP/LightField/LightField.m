classdef LightField < AbstractLightField
    
    properties (SetAccess = private)
        cameraPlane;
        sensorPlane;
    end
    
    properties (Dependent, SetAccess = private)
        distanceCameraToSensorPlane;
    end
    
    methods
        
        function this = LightField(lightFieldData, cameraPlane, sensorPlane)
            this = this@AbstractLightField(lightFieldData);
            % TODO: write invariant to check if resolution of
            % lightFieldData corrensponds to resolution of cameraPlane and
            % sensorPlane
            this.cameraPlane = cameraPlane;
            this.sensorPlane = sensorPlane;
        end
        
        function distance = get.distanceCameraToSensorPlane(this)
            distance = abs(this.cameraPlane.z - this.sensorPlane.z);
        end
        
    end
    
end

