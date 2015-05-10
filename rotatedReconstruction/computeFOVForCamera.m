function [ fov ] = computeFOVForCamera( distanceCameraPlaneToSensorPlane, ...
                                        aspectRatio )
% Computes the horizontal and vertical field of view of the camera given
% the distance of the center of projection to the sensor plane and the
% aspect ratio (width / height).

fovHorizontal = 2 * atan(0.5 / distanceCameraPlaneToSensorPlane);
fovVertical = fovHorizontal / aspectRatio;

fov = [fovHorizontal, fovVertical];

end

