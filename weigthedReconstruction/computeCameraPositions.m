function [ cameraPositionMatrixY, ...
           cameraPositionMatrixX ] = computeCameraPositions( cameraGridResolution, ... 
                                                             distanceBetweenTwoCameras )
% See also: computeCenteredGridPositions.m 

[ cameraPositionMatrixY, cameraPositionMatrixX] = computeCenteredGridPositions(cameraGridResolution, ... 
                                                                               distanceBetweenTwoCameras);

end

