classdef LightFieldEditor < handle
    %LIGHTFIELDEDITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        lightFieldData;
        cameraPlane;
        sensorPlane;
    end
    
    properties
        angularResolution;
        spatialResolution;
        sliceIndices;
    end
    
    methods
        
        function self = LightFieldEditor()
        end
        
        function lightField = getLightField(self)
            lightField = LightField(self.lightFieldData, self.cameraPlane, self.sensorPlane);
        end
        
        function loadData(self, pathToFolder, filetype, angularResolution, resizeScale)
            self.lightFieldData = loadLightFieldFromFolder(pathToFolder, filetype, angularResolution, resizeScale);
        end
    end
    
end

