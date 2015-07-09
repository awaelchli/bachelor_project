classdef LightFieldP < LightField
    
    properties (SetAccess = private)
        cameraPlane;
        sensorPlane;
    end
    
    properties (Dependent, SetAccess = private)
        distanceCameraToSensorPlane;
    end
    
    methods
        
        function this = LightFieldP(lightFieldData, cameraPlane, sensorPlane)
            this = this@LightField(lightFieldData);
            this.cameraPlane = cameraPlane;
            this.sensorPlane = sensorPlane;
            this.assertInvariant();
        end
        
        function distance = get.distanceCameraToSensorPlane(this)
            distance = abs(this.cameraPlane.z - this.sensorPlane.z);
        end
        
    end
    
    methods (Access = protected)
        
        function assertInvariant(this)
            this.assertInvariant@LightField();
            assert(all(this.cameraPlane.resolution == this.angularResolution), ...
                   'assertInvariant:wrongAngularResolution', ...
                   'The resolution of the camera plane must match the dimensions of the data.');
            assert(all(this.sensorPlane.planeResolution == this.spatialResolution), ...
                   'assertInvariant:wrongSpatialResolution', ...
                   'The resolution of the sensor plane must match the dimensions of the data.');
        end
        
    end
    
end

