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
        
        function pixelSize = get.pixelSize(this)
            pixelSize = this.planeSize ./ this.planeResolution;
        end
        
        function [ positionsY, positionsX ] = pixelPositionMatrices(this)
            [ positionsY, positionsX ] = computeCenteredGridPositions(this.planeResolution, this.pixelSize);
        end
        
        function positionsY = get.pixelPositionMatrixY(this)
            [ positionsY, ~ ] = pixelPositionMatrices(this);
        end
        
        function positionsX = get.pixelPositionMatrixX(this)
            [ ~, positionsX ] = pixelPositionMatrices(this);
        end
        
    end
    
end

