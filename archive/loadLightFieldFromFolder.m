function [ lightField, channels ] = loadLightFieldFromFolder( path, filetype, angularRes, resizeScale )
%   path:               Path to the image files. Assume images are sorted to
%                       represent the light field row by row.
%
%   filetype:           Type of the image files
%
%   angularRes:         [angularResY, angularResX] The resolution of the camera
%                       grid
%   resizeScale:        Load a downsampled version of the light field,
%                       scaled by the given value

% Load images of desired filetype
imgList = dir([path '*.' filetype]);
numImages = size(imgList);

fprintf(['Images found: ', num2str(prod(numImages)), '\n']);

if(numImages ~= angularRes(1) * angularRes(2))
    error('Number of images do not correspond to angular resolution.\n');
end

% Load the first image to get the spatial resolution
first = im2double(imread([path imgList(1).name]));
height = ceil(resizeScale * size(first, 1));
width = ceil(resizeScale * size(first, 2));
channels = size(first, 3);

lightField = zeros([angularRes height width channels]);

% Load all images in this folder. Check if all the images have the same
% resolution.
i = 1;
for y = 1 : angularRes(1)
    for x = 1 : angularRes(2)
        
        image = im2double(imread([path imgList(i).name]));
        image = imresize(image, resizeScale, 'nearest');
        if(channels == 1)
            if (~isequal(size(image), [height, width]))
                error('Files have wrong resolution / number of channels.');
            end
        else
            if (~isequal(size(image), [height, width, channels]))
                error('Files have wrong resolution / number of channels.');
            end
        end
        
        lightField(y, x, :, :, :) = image;
        
        i = i + 1;
    end
end


end