function [ sampledLightField ] = downsampleLighField( originalLightField, scaleFactor )

originalResolution = size(originalLightField);
newResolution = originalResolution;
newResolution([3, 4]) = ceil(scaleFactor * originalResolution([3, 4]));

sampledLightField = zeros(newResolution);

for y = 1 : originalResolution(1)
    for x = 1 : originalResolution(2)
        sampledLightField(y, x, :, :, :) = imresize(squeeze(originalLightField(y, x, :, :, :)), scaleFactor, 'nearest');
    end
end


end

