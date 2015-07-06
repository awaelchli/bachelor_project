classdef LightFieldO < LightField
    
    properties (Constant)
        verticalFOVIndex = 1;
        horizontalFOVIndex = 2;
    end
    
    properties (SetAccess = private)
        sensorPlane;
        % Field of view of the light field in radians
        fov;
    end
    
    properties (Dependent, SetAccess = private)
        fovY;
        fovX;
    end
    
    methods
        
        function this = LightFieldO(lightFieldData, sensorPlane, fieldOfView)
            % TODO: check that dimensions of lightFieldData corresponds to dimensions of sensorPlane
            % TODO: check dimensions of fieldOfView
            this = this@LightField(lightFieldData);
            this.sensorPlane = sensorPlane;
            this.fov = fieldOfView;
        end
        
        function rayAngle = rayAngle(this, angularIndex)
            halfFOV = this.fov / 2;
            angularStep = this.fov ./ (this.angularResolution - 1);
            rayAngle = -halfFOV + (angularIndex - 1) .* angularStep;
        end
        
        function fovY = get.fovY(this)
            fovY = this.fov(LightFieldO.verticalFOVIndex);
        end
        
        function fovX = get.fovX(this)
            fovX = this.fov(LightFieldO.horizontalFOVIndex);
        end
        
    end
    
end

