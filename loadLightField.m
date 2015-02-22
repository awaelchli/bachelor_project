function [ lightField ] = loadLightField( path, filetype, resolution )
%   path:           Path to the image files. Assume images are sorted to 
%                   represent the light field row by row.
%
%   filetype:       Type of the image files
%
%   resolution:     [angularResY, angularResX, height, width, channels]

% Load images of desired filetype
imgList = dir([path '*.' filetype]);
numImages = size(imgList);

if(numImages ~= resolution(1) * resolution(2))
    error('Number of images do not correspond to angular resolution.');
end

lightField = zeros(resolution);

i = 1;
for y = 1 : resolution(1)
    for x = 1 : resolution(2)
        
        image = im2double(imread([path imgList(i).name]));

        if(~isequal(size(image), [resolution(3), resolution(4), resolution(5)]))
            error('Files have wrong resolution / number of channels.');
        end
        
        lightField(y, x, :, :, :) = image;
        
        i = i + 1;
    end
end

end

