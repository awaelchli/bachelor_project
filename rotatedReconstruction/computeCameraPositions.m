function [ cameraPositionMatrixY, ...
           cameraPositionMatrixX ] = computeCameraPositions( cameraGridResolution, ... 
                                                             distanceBetweenTwoCameras )
% arrays [Y, X]
% 

[ cameraPositionMatrixY, cameraPositionMatrixX] = computeCenteredGridPositions(cameraGridResolution, ... 
                                                                               distanceBetweenTwoCameras);

end

