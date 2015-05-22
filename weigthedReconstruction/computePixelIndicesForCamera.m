function [ pixelIndexMatrixY, ...
           pixelIndexMatrixX, ...
           weightMatrix ] = computePixelIndicesForCamera( pixelPositionMatrixY, ...
                                                          pixelPositionMatrixX, ...
                                                          distanceCameraPlaneToSensorPlane, ...
                                                          fov, ...
                                                          cameraResolution, ...
                                                          floorCeilOrRoundHandle )

                                                      
maxPositionY = distanceCameraPlaneToSensorPlane * tan( fov(1) / 2);
maxPositionX = distanceCameraPlaneToSensorPlane * tan( fov(2) / 2);

sensorSize = [2 * maxPositionY, 2 * maxPositionX];
scalePositionToIndex = (cameraResolution - 1) ./ sensorSize;

% To 'screen' coordinate system
pixelPositionMatrixY = maxPositionY - pixelPositionMatrixY;
pixelPositionMatrixX = pixelPositionMatrixX + maxPositionX;

pixelPositionMatrixY(pixelPositionMatrixY < 0) = 0;
pixelPositionMatrixX(pixelPositionMatrixX < 0) = 0;
pixelPositionMatrixY(pixelPositionMatrixY > sensorSize(1)) = 0;
pixelPositionMatrixX(pixelPositionMatrixX > sensorSize(2)) = 0;

% Scale positions to the range [0, resolution - 1]
pixelPositionMatrixY = scalePositionToIndex(1) .* pixelPositionMatrixY;
pixelPositionMatrixX = scalePositionToIndex(2) .* pixelPositionMatrixX;

% Add one to the valid coordinates so that they are in range of [1, resolution]
pixelPositionMatrixY(pixelPositionMatrixY ~= 0) = pixelPositionMatrixY(pixelPositionMatrixY ~= 0) + 1;
pixelPositionMatrixX(pixelPositionMatrixX ~= 0) = pixelPositionMatrixX(pixelPositionMatrixX ~= 0) + 1;

pixelIndexMatrixY = floorCeilOrRoundHandle(pixelPositionMatrixY);
pixelIndexMatrixX = floorCeilOrRoundHandle(pixelPositionMatrixX);

% Maximum distance from rounded/floored/ceiled values is 0.5
distanceFromFloorCeilOrRoundY = pixelPositionMatrixY - pixelIndexMatrixY;
distanceFromFloorCeilOrRoundX = pixelPositionMatrixX - pixelIndexMatrixX;

data = cat(3, distanceFromFloorCeilOrRoundY, distanceFromFloorCeilOrRoundX);
data = reshape(data, [], 2);

mu = [0, 0];
sigma = [ 0.4 , 0;
          0, 0.4 ];
      
weights = mvnpdf(data, mu, sigma);

weightMatrix = reshape(weights, size(pixelIndexMatrixY));

end

