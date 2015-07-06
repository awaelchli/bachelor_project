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
        height;
        width;
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
        
        function height = get.height(self)
            height = self.planeSize(1);
        end
        
        function width = get.width(self)
            width = self.planeSize(2);
        end
        
        function [Y, X, validIndices] = positionToPixelCoordinates(this, Y, X)
            
            maxPositionY = this.height / 2;
            maxPositionX = this.width / 2;

            scalePositionToIndex = (this.planeResolution - 1) ./ this.planeSize;

            % To 'screen' coordinate system
            Y = maxPositionY - Y;
            X = X + maxPositionX;

            validIndices = Y >= 0 & X >= 0 & Y <= this.planeSize(1) & X <= this.planeSize(2);
            
            Y(~validIndices) = 0;
            X(~validIndices) = 0;

            % Scale positions to the range [0, resolution - 1]
            Y = scalePositionToIndex(1) .* Y;
            X = scalePositionToIndex(2) .* X;

            % Add one to the valid coordinates so that they are in range of [1, resolution]
            Y(validIndices) = Y(validIndices) + 1;
            X(validIndices) = X(validIndices) + 1;

            % In case the plane is 1D, correct the indices and positions
            if(this.planeResolution(1) == 1)
                Y = ones(size(Y));
            end
            
            if(this.planeResolution(2) == 1)
                X = ones(size(X));
            end
            
        end
        
    end
    
    methods (Static)
        
        function valid = isValidIndex(index, resolution)
            valid = numel(index) == 2 && ...
                    all(index <= resolution) && ...
                    all(index >= [1, 1]) && ...
                    all(~mod(index, 1));
        end

    end
    
end

