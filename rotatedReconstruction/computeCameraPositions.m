function [ cameraPositionMatrixY, ...
           cameraPositionMatrixX ] = computeCameraPositions( cameraGridResolution, ... 
                                                             distanceBetweenTwoCameras )
% arrays [Y, X]
% 

planeSize = (cameraGridResolution - 1) .* distanceBetweenTwoCameras;

positionsVectorY = planeSize(1) / 2 : -distanceBetweenTwoCameras(1) : -planeSize(1) / 2;
positionsVectorX = -planeSize(2) / 2 : distanceBetweenTwoCameras(2) : planeSize(2) / 2;

cameraPositionMatrixY = repmat(positionsVectorY', 1, cameraGridResolution(2));
cameraPositionMatrixX = repmat(positionsVectorX, cameraGridResolution(1), 1);

% cameraPositionMatrixY
% cameraPositionMatrixX
end

