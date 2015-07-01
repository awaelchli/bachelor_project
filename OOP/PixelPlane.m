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
        
        function [indicesY, indicesX, validIndices] = positionToIndex(this, Y, X)
            
            maxPositionY = this.planeSize(1) / 2;
            maxPositionX = this.planeSize(2) / 2;

            scalePositionToIndex = (this.planeResolution - 1) ./ this.planeSize;

            % To 'screen' coordinate system
            Y = maxPositionY - Y;
            X = X + maxPositionX;

            validIndices = Y >= 0 & X >= 0 & Y <= this.planeSize(1) & X <= this.planeSize(2);
            
            Y(~validIndices) = 0;
            X(~validIndices) = 0;
%             Y(Y < 0) = 0;
%             X(X < 0) = 0;
%             Y(Y > planeSize(1)) = 0;
%             X(X > planeSize(2)) = 0;

            % Scale positions to the range [0, resolution - 1]
            Y = scalePositionToIndex(1) .* Y;
            X = scalePositionToIndex(2) .* X;

            % Add one to the valid coordinates so that they are in range of [1, resolution]
            Y(validIndices) = Y(validIndices) + 1;
            X(validIndices) = X(validIndices) + 1;

            indicesY = round(Y);
            indicesX = round(X);

%             % In case the plane is 1D, correct the indices and positions
%             if(planeResolution(1) == 1)
%                 pixelIndexMatrixY = ones(planeResolution);
%                 Y = ones(planeResolution);
%             end
% 
%             if(planeResolution(2) == 1)
%                 pixelIndexMatrixX = ones(planeResolution);
%                 X = ones(planeResolution);
%             end
        end
        
    end
    
end

