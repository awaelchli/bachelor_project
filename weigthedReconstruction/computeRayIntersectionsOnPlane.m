function [ positionsOnSecondPlaneMatrixY, ...
           positionsOnSecondPlaneMatrixX ] = computeRayIntersectionsOnPlane( cameraPosition, ...
                                                                             cameraPlaneZ, ...
                                                                             firstPlaneZ, ...
                                                                             secondPlaneZ, ...
                                                                             positionsOnFirstPlaneMatrixY, ...
                                                                             positionsOnFirstPlaneMatrixX )
% arrays: [Y, X]

distanceBetweenCameraPlaneAndFirstPlane = cameraPlaneZ - firstPlaneZ;
distanceBetweenCameraPlaneAndSecondPlane = cameraPlaneZ - secondPlaneZ;


% Shift positions to camera coordinate system
positiosOnFirstPlaneRelativeToCameraMatrixY = positionsOnFirstPlaneMatrixY - cameraPosition(1);
positiosOnFirstPlaneRelativeToCameraMatrixX = positionsOnFirstPlaneMatrixX - cameraPosition(2);

% Project positions from first layer to the new layer
positionsOnSecondPlaneMatrixY = positiosOnFirstPlaneRelativeToCameraMatrixY .* distanceBetweenCameraPlaneAndSecondPlane / distanceBetweenCameraPlaneAndFirstPlane;
positionsOnSecondPlaneMatrixX = positiosOnFirstPlaneRelativeToCameraMatrixX .* distanceBetweenCameraPlaneAndSecondPlane ./ distanceBetweenCameraPlaneAndFirstPlane;

% Shift back positions to layer coordinate system
positionsOnSecondPlaneMatrixY = positionsOnSecondPlaneMatrixY + cameraPosition(1);
positionsOnSecondPlaneMatrixX = positionsOnSecondPlaneMatrixX + cameraPosition(2);
end

