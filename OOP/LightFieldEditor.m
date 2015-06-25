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
        
        function self = LightFieldEditor()
        end
        
        function lightField = getLightField(self)
            if(isempty(self.lightFieldData))
                error('No light field loaded yet!')
            end
            cameraPlane = CameraPlane(self.angularResolution, self.distanceBetweenTwoCameras, self.cameraPlaneZ);
            sensorPlane = SensorPlane(self.spatialResolution, self.sensorSize, self.sensorPlaneZ);
            lightField = LightField(self.lightFieldData(self.sliceIndices{:}), cameraPlane, sensorPlane);
        end
        
        function loadData(self, pathToFolder, filetype, angularResolution, resizeScale)
            self.lightFieldData = loadLightFieldFromFolder(pathToFolder, filetype, angularResolution, resizeScale);
            fullResolution = size(self.lightFieldData);
            self.sliceIndices{LightField.angularDimensions(1)} = 1 : fullResolution(1);
            self.sliceIndices{LightField.angularDimensions(2)} = 1 : fullResolution(2);
            self.sliceIndices{LightField.spatialDimensions(1)} = 1 : fullResolution(3);
            self.sliceIndices{LightField.spatialDimensions(2)} = 1 : fullResolution(4);
            self.sliceIndices{LightField.channelDimension} = 1 : fullResolution(5);
        end
        
        function resolution = get.resolution(self)
            resolution = cellfun(@numel, self.sliceIndices);
            resolution = resolution([LightField.angularDimensions, LightField.spatialDimensions]);
        end
        
        function angularResolution = get.angularResolution(self)
            angularResolution = self.resolution(LightField.angularDimensions);
        end
        
        function spatialResolution = get.spatialResolution(self)
            spatialResolution = self.resolution(LightField.spatialDimensions);
        end
        
        function channels = get.channels(self)
            resolution = cellfun(@numel, self.sliceIndices);
            channels = resolution(LightField.channelDimension);
        end
        
        function angularSliceY(self, indices)
            self.slice(indices, LightField.angularDimensions(1));
        end
        
        function angularSliceX(self, indices)
            self.slice(indices, LightField.angularDimensions(2));
        end
        
        function spatialSliceY(self, indices)
            self.slice(indices, LightField.spatialDimensions(1));
        end
        
        function spatialSliceX(self, indices)
            self.slice(indices, LightField.spatialDimensions(2));
        end
        
        function channelSlice(self, indices)
            self.slice(indices, LightField.channelDimension);
        end
        
    end
    
    methods (Access = private)
        
        function slice(self, indices, dimensionIndex)
            if(~LightFieldEditor.isValidSlice(indices, dimensionIndex, self.resolution))
                error('Invalid slice for current light field.');
            end
            self.sliceIndices{dimensionIndex} = unique(indices);
        end
    
    end
    
    methods (Static)
        
        function valid = isValidSlice(indices, dimensionIndex, resolution)
            valid = all(0 < indices) & ...
                    all(resolution(dimensionIndex) >= indices);
        end
        
    end
    
end

