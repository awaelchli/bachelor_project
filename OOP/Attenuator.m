classdef Attenuator < PixelPlane
    %ATTENUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        layerDimension = 1;
        spatialDimensions = [2, 3];
        channelDimension = 4;
        minimumNumberOfLayers = 2;
    end
    
    properties
        attenuationValues;
    end
    
    properties (Dependent, SetAccess = protected)
        planeResolution;
    end
    
    properties (SetAccess = protected)
        planeSize;
    end
    
    properties (SetAccess = private)
        distanceBetweenLayers;
    end
    
    properties (Dependent, SetAccess = private)
        numberOfLayers;
        channels;
        thickness;
        layerPositionZ;
    end
    
    
    methods
        
        function self = Attenuator(numberOfLayers, layerResolution, layerSize, distanceBetweenLayers, channels)
            if(numberOfLayers < Attenuator.minimumNumberOfLayers)
                error('Attenuator must have a minimum of %i layers.', Attenuator.minimumNumberOfLayers);
            end
            self.planeSize = layerSize;
            self.distanceBetweenLayers = distanceBetweenLayers;
            self.attenuationValues = zeros([numberOfLayers, layerResolution, channels]);
        end
        
        function numberOfLayers = get.numberOfLayers(self)
            numberOfLayers = size(self.attenuationValues, Attenuator.layerDimension);
        end
        
        function channels = get.channels(self)
            channels = size(self.attenuationValues, Attenuator.channelDimension);
        end
        
        function planeResolution = get.planeResolution(self)
            planeResolution = size(self.attenuationValues);
            planeResolution = planeResolution(Attenuator.spatialDimensions);
        end
        
        function planeSize = get.planeSize(self)
            planeSize = self.planeSize;
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

