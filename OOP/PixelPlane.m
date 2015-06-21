classdef PixelPlane < handle
    %SENSORPLANE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract, SetAccess = protected)
        planeResolution;
        planeSize;
    end
    
    properties (Dependent, SetAccess = private)
        pixelSize;
        pixelPositionMatrixY;
        pixelPositionMatrixX;
    end
    
    methods
        
        function pixelSize = get.pixelSize(self)
            pixelSize = self.planeSize ./ self.planeResolution;
        end
        
        function [ positionsY, positionsX ] = pixelPositionMatrices(self)
            [ positionsY, positionsX ] = computeCenteredGridPositions(self.planeResolution, self.pixelSize);
        end
        
        function positionsY = get.pixelPositionMatrixY(self)
            [ positionsY, ~ ] = pixelPositionMatrices(self);
        end
        
        function positionsX = get.pixelPositionMatrixX(self)
            [ ~, positionsX ] = pixelPositionMatrices(self);
        end
        
    end
    
end

