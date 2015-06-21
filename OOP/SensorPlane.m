classdef SensorPlane < PixelPlane
    %SENSORPLANE Summary of this class goes here
    %   Detailed explanation goes here
    
    % Properties from superclass
    properties (SetAccess = protected)
        planeResolution;
        planeSize;
    end
    
    properties (SetAccess = private)
        sensorPlaneZ;
    end
    
    methods
        
        function self = SensorPlane(sensorResolution, sensorSize, z)
            self.planeResolution = sensorResolution;
            self.planeSize = sensorSize;
            self.sensorPlaneZ = z;
        end
        
    end
    
end

