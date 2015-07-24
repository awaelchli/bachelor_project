function layersWithMarkers = addMarkersToLayers(layers, markerSize)

    resolution = [size(layers, 2), size(layers, 3)];

    markerPositions = [markerSize, markerSize;
                       resolution(2) - markerSize + 1, markerSize;
                       markerSize, resolution(1) - markerSize + 1;
                       resolution([2, 1]) - markerSize + 1];

    layersWithMarkers = layers;
    
    for i = 1 : size(markerPositions, 1)
        
        center = markerPositions(i, :);
        
        verticalY = center(1) - markerSize + 1 : 1 : center(1) + markerSize - 1;
        verticalX = repmat(center(2), size(verticalY));
        horizontalX = center(2) - markerSize + 1 : 1 : center(2) + markerSize - 1;
        horizontalY = repmat(center(1), size(horizontalX));
        
        layersWithMarkers(:, verticalY, verticalX, :) = 0;
        layersWithMarkers(:, horizontalY, horizontalX, :) = 0;
    end
    
end