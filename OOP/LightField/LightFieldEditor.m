classdef LightFieldEditor < handle
    %LIGHTFIELDEDITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        lightFieldData;
        sliceIndices = cell(1, LightField.lightFieldDimension + 1);
    end
    
    properties
        distanceBetweenTwoCameras = [1, 1];
        cameraPlaneZ = 1;
        sensorSize = [1, 1];
        sensorPlaneZ = 0;
    end
    
    properties (Dependent, SetAccess = private)
        resolution;
        angularResolution;
        spatialResolution;
        channels;
    end
    
    methods
        
        function this = LightFieldEditor()
        end
        
        function lightField = getLightField(this)
            if(isempty(this.lightFieldData))
                error('No light field loaded yet!')
            end
            cameraPlane = CameraPlane(this.angularResolution, this.distanceBetweenTwoCameras, this.cameraPlaneZ);
            sensorPlane = SensorPlane(this.spatialResolution, this.sensorSize, this.sensorPlaneZ);
            lightField = LightField(this.lightFieldData(this.sliceIndices{:}), cameraPlane, sensorPlane);
        end
        
        function loadData(this, pathToFolder, filetype, angularResolution, resizeScale)
            this.lightFieldData = loadLightFieldFromFolder(pathToFolder, filetype, angularResolution, resizeScale);
            fullResolution = size(this.lightFieldData);
            if(numel(fullResolution) == 4)
                % Greyscale
                fullResolution(5) = 1;
            end
            this.sliceIndices{LightField.angularDimensions(1)} = 1 : fullResolution(1);
            this.sliceIndices{LightField.angularDimensions(2)} = 1 : fullResolution(2);
            this.sliceIndices{LightField.spatialDimensions(1)} = 1 : fullResolution(3);
            this.sliceIndices{LightField.spatialDimensions(2)} = 1 : fullResolution(4);
            this.sliceIndices{LightField.channelDimension} = 1 : fullResolution(5);
        end
        
        function resolution = get.resolution(this)
            resolution = cellfun(@numel, this.sliceIndices);
            resolution = resolution([LightField.angularDimensions, LightField.spatialDimensions]);
        end
        
        function angularResolution = get.angularResolution(this)
            angularResolution = this.resolution(LightField.angularDimensions);
        end
        
        function spatialResolution = get.spatialResolution(this)
            spatialResolution = this.resolution(LightField.spatialDimensions);
        end
        
        function channels = get.channels(this)
            resolution = cellfun(@numel, this.sliceIndices);
            channels = resolution(LightField.channelDimension);
        end
        
        function angularSliceY(this, indices)
            this.slice(indices, LightField.angularDimensions(1));
        end
        
        function angularSliceX(this, indices)
            this.slice(indices, LightField.angularDimensions(2));
        end
        
        function spatialSliceY(this, indices)
            this.slice(indices, LightField.spatialDimensions(1));
        end
        
        function spatialSliceX(this, indices)
            this.slice(indices, LightField.spatialDimensions(2));
        end
        
        function channelSlice(this, indices)
            this.slice(indices, LightField.channelDimension);
        end
        
    end
    
    methods (Access = private)
        
        function slice(this, indices, dimensionIndex)
            if(~LightFieldEditor.isValidSlice(indices, dimensionIndex, this.resolution))
                error('Invalid slice for current light field.');
            end
            this.sliceIndices{dimensionIndex} = unique(indices);
        end
    
    end
    
    methods (Static)
        
        function valid = isValidSlice(indices, dimensionIndex, resolution)
            valid = all(0 < indices) & ...
                    all(resolution(dimensionIndex) >= indices);
        end
        
    end
    
end

