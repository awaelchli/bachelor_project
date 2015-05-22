function [ rectified_lightField ] = shearLightField( lightField, shiftY, shiftX )
% Assume the image grid is sorted left to right in horizontal direction, 
% and top to bottom in vertical direction

numberOfCameras = [size(lightField, 1), size(lightField, 2)];

cutSizesTop = (numberOfCameras(1) - 1) * shiftY : -shiftY : 0;
cutSizesLeft = (numberOfCameras(2) - 1) * shiftX : -shiftX : 0;

originalHeight = size(lightField, 3);
originalWidth = size(lightField, 4);

newHeight = originalHeight - cutSizesTop(1);
newWidth = originalWidth - cutSizesLeft(1);

rectified_lightField = zeros([numberOfCameras, newHeight, newWidth, size(lightField, 5)]);

for y = 1 : size(lightField, 1)
    for x = 1 : size(lightField, 2)
    
        image = squeeze(lightField(y, x, :, :, :));
        top = cutSizesTop(y);
        left = cutSizesLeft(x);
        rectified_image = image(top + 1 : top + newHeight, left + 1 : left + newWidth, :);
        rectified_lightField(y, x, :, :, :) = rectified_image;
        
    end
end


end

