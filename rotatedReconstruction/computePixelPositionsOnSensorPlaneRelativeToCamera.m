function [ pixelPositionMatrixY, ...
           pixelPositionMatrixX] = computePixelPositionsOnSensorPlaneRelativeToCamera( cameraPosition, ...
                                                                                       focalLength, ...
                                                                                       distanceBetweenCameraPlaneAndLayer, ...
                                                                                       layerPositionMatrixY, ...
                                                                                       layerPositionMatrixX)
% arrays: [Y, X]
% lengths in mm

% Shift positions so that they are relative to the camera
positionMatrixYRelativeToCam = -(cameraPosition(1) - layerPositionMatrixY); 
positionMatrixXRelativeToCam = -(cameraPosition(2) - layerPositionMatrixX); 

% Compute the positions on the sensor plane of the camera
pixelPositionMatrixY = positionMatrixYRelativeToCam .* focalLength ./ distanceBetweenCameraPlaneAndLayer;
pixelPositionMatrixX = positionMatrixXRelativeToCam .* focalLength ./ distanceBetweenCameraPlaneAndLayer;

% pixelPositionMatrixY
% pixelPositionMatrixX
end

