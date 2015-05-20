function [ pixelPositionMatrixY, ...
           pixelPositionMatrixX] = computePixelPositionsOnSensorPlaneRelativeToCamera( cameraPosition, ...
                                                                                       distanceCameraPlaneToSensorPlane, ...
                                                                                       distanceBetweenCameraPlaneAndLayer, ...
                                                                                       pixelPositionOnLayerMatrixY, ...
                                                                                       pixelPositionOnLayerMatrixX)
% arrays: [Y, X]
% lengths in mm

% Shift positions so that they are relative to the camera
positionMatrixYRelativeToCam = pixelPositionOnLayerMatrixY - cameraPosition(1);
positionMatrixXRelativeToCam = pixelPositionOnLayerMatrixX - cameraPosition(2); 

% Compute the positions on the sensor plane of the camera
pixelPositionMatrixY = positionMatrixYRelativeToCam .* distanceCameraPlaneToSensorPlane ./ distanceBetweenCameraPlaneAndLayer;
pixelPositionMatrixX = positionMatrixXRelativeToCam .* distanceCameraPlaneToSensorPlane ./ distanceBetweenCameraPlaneAndLayer;

% pixelPositionMatrixX
end

