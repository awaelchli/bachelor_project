classdef CameraPlane < handle
    %CAMERAPLANE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        cameraPositionMatrixY;
        cameraPositionMatrixX;
        z;
    end
    
    properties (Dependent, SetAccess = private)
        size;
        resolution;
        distanceBetweenTwoCameras;
    end
    
    methods
        
        function self = CameraPlane(gridResolution, distanceBetweenTwoCameras, z)
            self.z = z;
            [ self.cameraPositionMatrixY, ...
              self.cameraPositionMatrixX ] = computeCenteredGridPositions(gridResolution, distanceBetweenTwoCameras);
        end
        
        function size = get.size(self)
            resolution = self.resolution;
            height = 2 * self.cameraPositionMatrixY(1, 1);
            width = 2 * self.cameraPositionMatrixX(1, resolution(2));
            size = [height, width];
        end
        
        function resolution = get.resolution(self)
            resolution = size(self.cameraPositionMatrixY);
        end
        
        function distance = get.distanceBetweenTwoCameras(self)
            distance = [0, 0];
            
            if(self.resolution(1) > 1)
                distance(1) = self.cameraPositionMatrixY(1, 1) - ...
                              self.cameraPositionMatrixY(2, 1);
            end
            if(self.resolution(2) > 1)
                distance(2) = self.cameraPositionMatrixX(1, 2) - ...
                              self.cameraPositionMatrixX(1, 1);
            end
        end
        
    end
    
end

