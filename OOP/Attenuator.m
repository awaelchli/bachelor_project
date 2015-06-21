classdef Attenuator < PixelPlane
    %ATTENUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        attenuationValues;
    end
    
    properties (Dependent, Access = protected)
        resolution;
    end
    
    properties (Access = protected)
        planeSize;
    end
    
    properties (SetAccess = private)
        layerSize; % Alias of planeSize from superclass
        distanceBetweenLayers;
    end
    
    properties (Dependent, SetAccess = private)
        layerResolution; % Alias of resolution from superclass
        numberOfLayers;
        channels;
        thickness;
        layerPositionZ;
    end
    
    
    methods
        
        function self = Attenuator(numberOfLayers, layerResolution, layerSize, distanceBetweenLayers, channels)
            if(numberOfLayers < 2)
                error('Attenuator must have a minimum of 2 layers.');
            end
            self.planeSize = layerSize;
            self.distanceBetweenLayers = distanceBetweenLayers;
            self.attenuationValues = zeros([numberOfLayers, layerResolution, channels]);
        end
        
        function numberOfLayers = get.numberOfLayers(self)
            numberOfLayers = size(self.attenuationValues, 1);
        end
        
        function channels = get.channels(self)
            channels = size(self.attenuationValues, 4);
        end
        
        function resolution = get.resolution(self)
            resolution = size(self.attenuationValues);
            resolution = resolution([2, 3]);
        end
        
        function layerResolution = get.layerResolution(self)
            layerResolution = self.resolution;
        end
        
        function layerSize = get.layerSize(self)
            layerSize = self.planeSize;
        end
        
        function thickness = get.thickness(self)
            thickness = (self.numberOfLayers - 1) * self.distanceBetweenLayers;
        end
        
        function layerPositionZ = get.layerPositionZ(self)
            d = self.distanceBetweenLayers;
            layerPositionZ = -self.thickness / 2 : d : self.thickness / 2;
        end
        
    end
    
end

