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
        spatialAspectRatio;
        angularAspectRatio;
    end
    
    methods
        
        function this = LightField(lightFieldData)
            this.lightFieldData = lightFieldData;
            this.assertLightFieldDataSize();
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
        
        function aspect = get.spatialAspectRatio(this)
            aspect = this.spatialResolution(2) / this.spatialResolution(1);
        end
        
        function aspect = get.angularAspectRatio(this)
            aspect = this.angularResolution(2) / this.angularResolution(1);
        end
        
        function replaceView(this, angularIndexY, angularIndexX, image)
            this.lightFieldData(angularIndexY, angularIndexX, : , : , :) = image;
            this.assertInvariant();
        end
        
        function valid = isValidAngularIndex(this, index)
            valid = PixelPlane.isValidIndex(index, this.angularResolution);
        end
        
        function valid = isValidSpatialIndex(this, index)
            valid = PixelPlane.isValidIndex(index, this.spatialResolution);
        end
        
        function lightFieldVector = vectorizeData(this)
            lightFieldVector = reshape(this.lightFieldData, [], this.channels);
        end
        
    end
    
    methods (Access = protected)
        
        function assertInvariant(this)
            this.assertLightFieldDataSize();
        end
        
    end
    
    methods (Access = private)
        
        function assertLightFieldDataSize(this)
            assert(numel(size(this.lightFieldData)) >= LightField.lightFieldDimension, ...
                   'assertLightFieldDataSize:dataHasWrongNumberOfDimensions', ...
                   'The light field data must be a 4D or 5D array.');
        end
        
    end
    
end

