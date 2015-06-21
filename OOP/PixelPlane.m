classdef PixelPlane < handle
    %SENSORPLANE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract, Access = protected)
        resolution;
        planeSize;
    end
    
    properties (Dependent, SetAccess = private)
        pixelSize;
        pixelPositionMatrixY;
        pixelPositionMatrixX;
    end
    
    methods
        
        function pixelSize = get.pixelSize(self)
            pixelSize = self.planeSize ./ self.resolution;
        end
        
        function [ positionsY, positionsX ] = pixelPositionMatrices(self)
            [ positionsY, positionsX ] = computeCenteredGridPositions(self.resolution, self.pixelSize);
        end
        
        function positionsY = get.pixelPositionMatrixY(self)
            [ positionsY, ~ ] = pixelPositionMatrices(self);
        end
        
        function positionsX = get.pixelPositionMatrixX(self)
            [ ~, positionsX ] = pixelPositionMatrices(self);
        end
        
    end
    
end

