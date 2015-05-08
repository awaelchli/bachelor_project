function [ fov ] = computeFOVForCamera( distanceCameraPlaneToSensorPlane, ...
                                                aspectRatio )
% fov = [fovHorizontal, fovVertical]

fovHorizontal = 2 * atan(0.5 / distanceCameraPlaneToSensorPlane);
fovVertical = fovHorizontal / aspectRatio;

fov = [fovHorizontal, fovVertical];

end

