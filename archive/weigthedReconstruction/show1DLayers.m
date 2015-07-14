function [  ] = show1DLayers( layers, replicationSize )

NumberOfLayers = size(layers, 3);
layerResolution = [ size(layers, 1), size(layers, 2) ];

if(all(layerResolution ~= 1))
    error('The layers are not one dimensional.');
end

replicationDimensions = (layerResolution == 1) * replicationSize;
replicationDimensions(replicationDimensions == 0) = 1;

figure

for layer = 1 : NumberOfLayers
    
    layerImage = squeeze(layers(:, :, layer, :));
    layerImage = reshape(layerImage, layerResolution(1), layerResolution(2), []);
    layerImage = repmat(layerImage, replicationDimensions(1), replicationDimensions(2), 1); 
    

    subplot(NumberOfLayers, 1, layer)
    imshow(layerImage);
    
end


end

