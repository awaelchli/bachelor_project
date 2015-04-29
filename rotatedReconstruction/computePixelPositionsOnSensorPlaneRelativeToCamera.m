function [ pixelPositionMatrixY, ...
           pixelPositionMatrixX] = computePixelPositionsOnSensorPlaneRelativeToCamera( cameraPosition, ...
                                                                                       sensorPlaneDist, ...
                                                                                       distanceBetweenCameraPlaneAndLayer, ...
                                                                                       layerPositionMatrixY, ...
                                                                                       layerPositionMatrixX)
% arrays: [Y, X]
% lengths in mm

% Shift positions so that they are relative to the camera
positionMatrixYRelativeToCam = -(cameraPosition(1) - layerPositionMatrixY); 
positionMatrixXRelativeToCam = -(cameraPosition(2) - layerPositionMatrixX); 

% Compute the positions on the sensor plane of the camera
pixelPositionMatrixY = positionMatrixYRelativeToCam .* sensorPlaneDist ./ distanceBetweenCameraPlaneAndLayer;
pixelPositionMatrixX = positionMatrixXRelativeToCam .* sensorPlaneDist ./ distanceBetweenCameraPlaneAndLayer;

% pixelPositionMatrixY
% pixelPositionMatrixX
end

