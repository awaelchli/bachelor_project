function [ positionsOnNewLayerMatrixY, ...
           positionsOnNewLayerMatrixX ] = computeLayerPositionsOnNewLayerFromFirstLayer( cameraPosition, ...
                                                                                         distanceBetweenCameraPlaneAndFirstLayer, ...
                                                                                         distanceBetweenCameraPlaneAndCurrentLayer, ...
                                                                                         pixelPositionOnFirstLayerMatrixY, ...
                                                                                         pixelPositionOnFirstLayerMatrixX )
% arrays: [Y, X]

% Shift positions to camera coordinate system
positiosOnFirstLayerRelativeToCameraMatrixY = pixelPositionOnFirstLayerMatrixY - cameraPosition(1);
positiosOnFirstLayerRelativeToCameraMatrixX = pixelPositionOnFirstLayerMatrixX - cameraPosition(2);

% Project positions from first layer to the new layer
positionsOnNewLayerMatrixY = positiosOnFirstLayerRelativeToCameraMatrixY .* distanceBetweenCameraPlaneAndCurrentLayer / distanceBetweenCameraPlaneAndFirstLayer;
positionsOnNewLayerMatrixX = positiosOnFirstLayerRelativeToCameraMatrixX .* distanceBetweenCameraPlaneAndCurrentLayer ./ distanceBetweenCameraPlaneAndFirstLayer;

% Shift back positions to layer coordinate system
positionsOnNewLayerMatrixY = positionsOnNewLayerMatrixY + cameraPosition(1);
positionsOnNewLayerMatrixX = positionsOnNewLayerMatrixX + cameraPosition(2);
end

