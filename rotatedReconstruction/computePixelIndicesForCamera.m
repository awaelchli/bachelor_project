function [ pixelIndexMatrixY, ...
           pixelIndexMatrixX ] = computePixelIndicesForCamera( pixelPositionMatrixY, ...
                                                               pixelPositionMatrixX, ...
                                                               distanceCameraPlaneToSensorPlane, ...
                                                               fov, ...
                                                               cameraResolution, ...
                                                               floorCeilOrRoundHandle )
% lengths in mm
% arrays: [Y, X]


maxPositionY = distanceCameraPlaneToSensorPlane * tan( fov(1) / 2);
maxPositionX = distanceCameraPlaneToSensorPlane * tan( fov(2) / 2);

% minPositionY = -maxPositionY;
% minPositionX = -maxPositionX;

% TODO : check the sensor size and make compatible
sizeOfView = [2 * maxPositionY, 2 * maxPositionX];
scalePositionToIndex = (cameraResolution - 1) ./ sizeOfView;

% sizeOfView
% pixelPositionMatrixX

% To 'screen' coordinate system
pixelPositionMatrixY = maxPositionY - pixelPositionMatrixY;
pixelPositionMatrixX = pixelPositionMatrixX + maxPositionX;

% pixelPositionMatrixX

pixelPositionMatrixY(pixelPositionMatrixY < 0) = 0;
pixelPositionMatrixX(pixelPositionMatrixX < 0) = 0;
pixelPositionMatrixY(pixelPositionMatrixY > sizeOfView(1)) = 0;
pixelPositionMatrixX(pixelPositionMatrixX > sizeOfView(2)) = 0;

% pixelPositionMatrixX

% Scale positions to the range [0, resolution - 1]
pixelPositionMatrixY = scalePositionToIndex(1) .* pixelPositionMatrixY;
pixelPositionMatrixX = scalePositionToIndex(2) .* pixelPositionMatrixX;

% Add one to the valid coordinates so that they are in range of [1, resolution]
pixelPositionMatrixY(pixelPositionMatrixY ~= 0) = pixelPositionMatrixY(pixelPositionMatrixY ~= 0) + 1;
pixelPositionMatrixX(pixelPositionMatrixX ~= 0) = pixelPositionMatrixX(pixelPositionMatrixX ~= 0) + 1;

% pixelPositionMatrixX

pixelPositionMatrixY = floorCeilOrRoundHandle(pixelPositionMatrixY);
pixelPositionMatrixX = floorCeilOrRoundHandle(pixelPositionMatrixX);

% set all positions that fall out as 'invalid'
% pixelPositionMatrixY(pixelPositionMatrixY < 1) = 0;
% pixelPositionMatrixX(pixelPositionMatrixX < 1) = 0;
% pixelPositionMatrixY(pixelPositionMatrixY > cameraResolution(1)) = 0;
% pixelPositionMatrixX(pixelPositionMatrixX > cameraResolution(2)) = 0;

pixelIndexMatrixY = pixelPositionMatrixY;
pixelIndexMatrixX = pixelPositionMatrixX;

end

