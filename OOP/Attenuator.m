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
        
        function this = Attenuator(numberOfLayers, layerResolution, layerSize, distanceBetweenLayers, channels)
            if(numberOfLayers < Attenuator.minimumNumberOfLayers)
                error('Attenuator must have a minimum of %i layers.', Attenuator.minimumNumberOfLayers);
            end
            this.planeSize = layerSize;
            this.distanceBetweenLayers = distanceBetweenLayers;
            this.attenuationValues = zeros([numberOfLayers, layerResolution, channels]);
        end
        
        function numberOfLayers = get.numberOfLayers(this)
            numberOfLayers = size(this.attenuationValues, Attenuator.layerDimension);
        end
        
        function channels = get.channels(this)
            channels = size(this.attenuationValues, Attenuator.channelDimension);
        end
        
        function planeResolution = get.planeResolution(this)
            planeResolution = size(this.attenuationValues);
            planeResolution = planeResolution(Attenuator.spatialDimensions);
        end
        
        function planeSize = get.planeSize(this)
            planeSize = this.planeSize;
        end
        
        function thickness = get.thickness(this)
            thickness = (this.numberOfLayers - 1) * this.distanceBetweenLayers;
        end
        
        function layerPositionZ = get.layerPositionZ(this)
            d = this.distanceBetweenLayers;
            layerPositionZ = -this.thickness / 2 : d : this.thickness / 2;
        end
        
    end
    
end

