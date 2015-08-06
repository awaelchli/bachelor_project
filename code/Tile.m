classdef Tile < PixelPlane
    
    % Property from superclass
    properties (SetAccess = protected)
        planeResolution;
    end
    
    % Property from superclass
    properties (Dependent, SetAccess = protected)
        planeSize;
    end
    
    properties (SetAccess = private)
        parentPlane;
        pixelIndexInParentY;
        pixelIndexInParentX;
    end
    
    methods
        
        function this = Tile(parentPlane, location, tileResolution)
            % location: The pixel index in the parent plane of the top left corner pixel of this tile
            assert(PixelPlane.isValidIndex(location, parentPlane.planeResolution), ...
                   'Tile:InvalidTileLocation', ...
                   'The tile must be placed at a pixel lying within the parent plane.');
            this.parentPlane = parentPlane;
            this.initTileResolution(location, tileResolution)
            this.initTileCenter(location);
        end
        
        function planeSize = get.planeSize(this)
            planeSize = this.parentPlane.pixelSize .* this.planeResolution;
        end
        
    end
    
    methods (Access = private)
        
        function initTileResolution(this, location, planeResolution)
            indicesY = location(1) : location(1) + planeResolution(1) - 1;
            indicesX = location(2) : location(2) + planeResolution(2) - 1;
            indicesY = repmat(indicesY', 1, planeResolution(2));
            indicesX = repmat(indicesX, planeResolution(1), 1);
            
            % Reduce the resolution of this tile if it exeeds the limits of the parent plane
            fun = @(y, x) PixelPlane.isValidIndex([y, x], this.parentPlane.planeResolution);
            validIndices = arrayfun(fun, indicesY, indicesX);
            this.planeResolution = [nnz(validIndices(:, 1)), nnz(validIndices(1, :))];
            
            this.pixelIndexInParentY = indicesY(validIndices(:, 1), validIndices(1, :));
            this.pixelIndexInParentX = indicesX(validIndices(:, 1), validIndices(1, :));
        end
        
        function initTileCenter(this, location)
            [ positionsY, positionsX ] = this.parentPlane.pixelPositionMatrices();
            firstPixelPosition = [positionsY(location(1), location(2)), positionsX(location(1), location(2))];
            topLeftCornerPosition = firstPixelPosition + [this.pixelSize(1) / 2, -this.pixelSize(2) / 2];
            tileSize = this.parentPlane.pixelSize .* this.planeResolution;
            tileCenter = [topLeftCornerPosition(1) - tileSize(1) / 2, topLeftCornerPosition(2) + tileSize(2) / 2];
            this.translate(tileCenter);
        end
        
    end
    
end