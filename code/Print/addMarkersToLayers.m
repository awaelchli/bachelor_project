function layersWithMarkers = addMarkersToLayers(layers, markerSize)

    resolution = [size(layers, 2), size(layers, 3)];

    markerPositions = [markerSize, markerSize;
                       resolution(2) - markerSize, markerSize;
                       markerSize, resolution(1) - markerSize];
    layerNumberPosition = resolution([2, 1]) - markerSize;

    layersWithMarkers = zeros(size(layers));
    
    for number = 1 : size(layers, 1)
        imageWithMarkers = insertMarker(squeeze(layers(number, :, :, :)), markerPositions, ...
                                        'Color', 'black', ...
                                        'Size', markerSize);
        
        imageWithMarkers = insertText(imageWithMarkers, layerNumberPosition, num2str(number), ...
                                      'FontSize', markerSize, ...
                                      'AnchorPoint', 'Center', ...
                                      'BoxColor', 'white', ...
                                      'BoxOpacity', 1);
        
        figure; imshow(imageWithMarkers);
        layersWithMarkers(number, :, :, :) = imageWithMarkers;
    end
end