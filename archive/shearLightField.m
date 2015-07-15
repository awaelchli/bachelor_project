function [ rectifiedLightField ] = shearLightField( lightField, disparity )
% Assume the image grid is sorted left to right in horizontal direction, 
% and top to bottom in vertical direction

numberOfCameras = [size(lightField, 1), size(lightField, 2)];

cutSizesTop = (numberOfCameras(1) - 1) * disparity : -disparity : 0;
cutSizesLeft = (numberOfCameras(2) - 1) * disparity : -disparity : 0;

originalHeight = size(lightField, 3);
originalWidth = size(lightField, 4);

newHeight = originalHeight - cutSizesTop(1);
newWidth = originalWidth - cutSizesLeft(1);

rectifiedLightField = zeros([numberOfCameras, newHeight, newWidth, size(lightField, 5)]);

for y = 1 : size(lightField, 1)
    for x = 1 : size(lightField, 2)
    
        image = squeeze(lightField(y, x, :, :, :));
        top = cutSizesTop(y);
        left = cutSizesLeft(x);
        rectifiedImage = image(top + 1 : top + newHeight, left + 1 : left + newWidth, :);
        rectifiedLightField(y, x, :, :, :) = rectifiedImage;
        
    end
end


end

