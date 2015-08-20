classdef LightFieldEditor < handle
    
    properties (Constant, Access = private)
        inputTypeImageCollection = 'collection';
        inputTypeH5File = 'H5';
        inputTypeLytroFile = 'LytroLFR';
        resizeInterpolationMethod = 'bilinear';
    end
    
    properties (Access = private)
        lightFieldData;
        input;
        sliceIndices = cell(1, LightField.lightFieldDimension + 1);
    end
    
    properties
        distanceBetweenTwoCameras = [1, 1];
        cameraPlaneZ = 1;
        sensorSize = [1, 1];
        sensorPlaneZ = 0;
        lightFieldFOV = [1, 1];
    end
    
    properties (Dependent, SetAccess = private)
        resolution;
        angularResolution;
        spatialResolution;
        channels;
        inputFolder;
    end
    
    methods
        
        function this = LightFieldEditor()
            this.input.type = '';
            this.input.folder = '/';
            this.input.resizeScale = 1;
        end
        
        function lightField = getPerspectiveLightField(this)
            this.loadLightFieldData();
            cameraPlane = CameraPlane(this.angularResolution, this.distanceBetweenTwoCameras, this.cameraPlaneZ);
            sensorPlane = SensorPlane(this.spatialResolution, this.sensorSize, this.sensorPlaneZ);
            lightField = LightFieldP(this.lightFieldData, cameraPlane, sensorPlane);
        end
        
        function lightField = getOrthographicLightField(this)
            this.loadLightFieldData();
            sensorPlane = SensorPlane(this.spatialResolution, this.sensorSize, this.sensorPlaneZ);
            lightField = LightFieldO(this.lightFieldData, sensorPlane, this.lightFieldFOV);
        end
        
        function inputFromImageCollection(this, inputFolder, filetype, angularResolution, resizeScale)
            if(exist(inputFolder, 'dir') ~= 7)
                errorStruct.message = sprintf('The path "%s" is not a folder.', inputFolder);
                errorStruct.identifier = 'inputFromImageCollection:invalidFolder';
                error(errorStruct);
            end
            
            imageList = dir([inputFolder '*.' filetype]);
            numberOfImages = numel(imageList);
            if(numberOfImages ~= prod(angularResolution))
                errorStruct.message = 'Number of images do not correspond to angular resolution.';
                errorStruct.identifier = 'inputFromImageCollection:wrongAngularResolution';
                error(errorStruct);
            end
            
            if(0 >= resizeScale)
                errorStruct.message = 'The parameter "resizeScale" must be positive.';
                errorStruct.identifier = 'inputFromImageCollection:resizeScaleNotPositive';
                error(errorStruct);
            end
            
            this.input.type = LightFieldEditor.inputTypeImageCollection;
            this.input.folder = inputFolder;
            this.input.filetype = filetype;
            this.input.angularResolution = angularResolution;
            this.input.resizeScale = resizeScale;
            
            % Load the first image to get the spatial resolution and color channels
            firstImage = im2double(imread([inputFolder imageList(1).name]));
            this.input.spatialResolution = [size(firstImage, 1), size(firstImage, 2)];
            this.input.channels = size(firstImage, 3);
            
            this.initSliceIndices([angularResolution, ceil(resizeScale * this.input.spatialResolution), this.input.channels]);
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
        
        function folder = get.inputFolder(this)
            folder = this.input.folder;
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
        
        function initSliceIndices(this, fullResolution)
            this.sliceIndices{LightField.angularDimensions(1)} = 1 : fullResolution(1);
            this.sliceIndices{LightField.angularDimensions(2)} = 1 : fullResolution(2);
            this.sliceIndices{LightField.spatialDimensions(1)} = 1 : fullResolution(3);
            this.sliceIndices{LightField.spatialDimensions(2)} = 1 : fullResolution(4);
            this.sliceIndices{LightField.channelDimension} = 1 : fullResolution(5);
        end
        
        function slice(this, indices, dimensionIndex)
            if(~LightFieldEditor.isValidSlice(indices, dimensionIndex, [this.resolution, this.channels]))
                errorStruct.message = 'Invalid slice for current light field.';
                errorStruct.identifier = 'slice:invalidSlice';
                error(errorStruct);
            end
            this.sliceIndices{dimensionIndex} = indices;
        end

        function loadLightFieldData(this)
            switch(this.input.type)
                case LightFieldEditor.inputTypeImageCollection
                    this.loadDataFromImageCollection();
                otherwise
                    errorStruct.message = 'No input data specified.';
                    errorStruct.identifier = 'loadLightFieldData:noInputData';
                    error(errorStruct);
            end
        end
        
        function loadDataFromImageCollection(this)
            this.lightFieldData = zeros([this.resolution, this.channels]);
            angularSlicesY = this.sliceIndices{LightField.angularDimensions(1)};
            angularSlicesX = this.sliceIndices{LightField.angularDimensions(2)};
            spatialSlicesY = this.sliceIndices{LightField.spatialDimensions(1)};
            spatialSlicesX = this.sliceIndices{LightField.spatialDimensions(2)};
            channelSlices = this.sliceIndices{LightField.channelDimension};
            
            imageList = dir([this.input.folder '*.' this.input.filetype]);
            
            for y = 1 : this.angularResolution(1)
                for x = 1 : this.angularResolution(2)
                    
                    imageIndex = (angularSlicesY(y) - 1) * this.input.angularResolution(2) + angularSlicesX(x);
                    
                    image = im2double(imread([this.input.folder imageList(imageIndex).name]));
                    image = imresize(image, this.input.resizeScale, LightFieldEditor.resizeInterpolationMethod);
                    image = image(spatialSlicesY, spatialSlicesX, channelSlices);
                    this.lightFieldData(y, x, :, :, :) = image;
                end
            end
        end
    
    end
    
    methods (Static)
        
        function valid = isValidSlice(indices, dimensionIndex, resolution)
            valid = all(0 < indices) & ...
                    all(resolution(dimensionIndex) >= indices) & ...
                    all(~mod(indices, 1));
        end
        
        function rectifiedData = shear(lightFieldData, disparityShift)
            
            if(~isscalar(disparityShift) || disparityShift < 0)
                errorStruct.message = 'The disparity shift must be a positive scalar.';
                errorStruct.identifier = 'shear:disparityNotPositiveScalar';
                error(errorStruct);
            end
            
            if(numel(size(lightFieldData)) ~= LightField.lightFieldDimension + 1)
                errorStruct.message = 'The light field data must be a 5-dimensional array.';
                errorStruct.identifier = 'shear:wrongDimensionOfData';
                error(errorStruct);
            end
            
            if(disparityShift == 0)
                rectifiedData = lightFieldData;
                return;
            end
            
            resolution = size(lightFieldData);
            
            cutSizesTop = (resolution(LightField.angularDimensions(1)) - 1) * disparityShift : -disparityShift : 0;
            cutSizesLeft = (resolution(LightField.angularDimensions(2)) - 1) * disparityShift : -disparityShift : 0;
            newHeight = resolution(LightField.spatialDimensions(1)) - cutSizesTop(1);
            newWidth = resolution(LightField.spatialDimensions(2)) - cutSizesLeft(1);

            rectifiedData = zeros([resolution(LightField.angularDimensions), newHeight, newWidth, resolution(LightField.channelDimension)]);

            for cy = 1 : resolution(LightField.angularDimensions(1))
                for cx = 1 : resolution(LightField.angularDimensions(2))

                    image = squeeze(lightFieldData(cy, cx, :, :, :));
                    top = cutSizesTop(cy);
                    left = cutSizesLeft(cx);
                    rectifiedImage = image(top + 1 : top + newHeight, left + 1 : left + newWidth, :);
                    rectifiedData(cy, cx, :, :, :) = rectifiedImage;
                end
            end
        end
        
    end
    
end

