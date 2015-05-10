function [ sensorDistance ] = computeSensorDistanceOfCamera( fov )
% Computes the distance between the sensor and the center of projection of
% a camera, given the field of view [fovHorizontal, fovVertical] in
% horizontal and vertical direction (in radians). 

sensorDistance =  1 / (2 * tan(fov(1) / 2));

end

