classdef LightField < handle
    
    properties (Constant)
        lightFieldDimension = 4;
        angularDimensions = [1, 2];
        spatialDimensions = [3, 4];
        channelDimension = 5;
    end
    
    properties (SetAccess = protected)
        lightFieldData;
    end
    
    properties (Dependent, SetAccess = private)
        resolution;
        angularResolution;
        spatialResolution;
        channels;
    end
    
    methods
        
        function this = LightField(lightFieldData)
            % TODO: check dimensions of lightFieldData
            this.lightFieldData = lightFieldData;
        end
        
        function resolution = get.resolution(this)
            resolution = size(this.lightFieldData);
            resolution = resolution([LightField.angularDimensions, LightField.spatialDimensions]);
        end
        
        function angularResolution = get.angularResolution(this)
            angularResolution = this.resolution(LightField.angularDimensions);
        end
        
        function spatialResolution = get.spatialResolution(this)
            spatialResolution = this.resolution(LightField.spatialDimensions);
        end
        
        function channels = get.channels(this)
            channels = size(this.lightFieldData, LightField.channelDimension);
        end
        
        function replaceView(this, angularIndexY, angularIndexX, image)
           this.lightFieldData(angularIndexY, angularIndexX, : , : , :) = image; 
        end
        
        function valid = isValidAngularIndex(this, index)
            valid = PixelPlane.isValidIndex(index, this.angularResolution);
        end
        
        function valid = isValidSpatialIndex(this, index)
            valid = PixelPlane.isValidIndex(index, this.spatialResolution);
        end
        
    end
    
end

