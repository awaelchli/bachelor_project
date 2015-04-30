function [ pixelIndexMatrixY, ...
           pixelIndexMatrixX ] = computePixelIndicesForCamera( pixelPositionMatrixY, ...
                                                               pixelPositionMatrixX, ...
                                                               focalLength, ...
                                                               fov, ...
                                                               cameraResolution, ...
                                                               floorOrCeilFunction )
% lengths in mm
% arrays: [Y, X]

maxPositionY = focalLength * tan( fov(1) / 2);
maxPositionX = focalLength * tan( fov(2) / 2);

% minPositionY = -maxPositionY;
% minPositionX = -maxPositionX;

% TODO : check the sensor size and make compatible
sizeOfView = [2 * maxPositionY, 2 * maxPositionX];
scalePositionToIndex = (cameraResolution - 1) ./ sizeOfView;

% To screen coordinate system
pixelPositionMatrixY = maxPositionY - pixelPositionMatrixY;
pixelPositionMatrixX = pixelPositionMatrixX + maxPositionX;

% Scale to pixel indices
pixelPositionMatrixY = scalePositionToIndex(1) .* pixelPositionMatrixY;
pixelPositionMatrixX = scalePositionToIndex(2) .* pixelPositionMatrixX;

pixelPositionMatrixY = floorOrCeilFunction(pixelPositionMatrixY);
pixelPositionMatrixX = floorOrCeilFunction(pixelPositionMatrixX);

% set all positions that fall out as 'invalid'
pixelPositionMatrixY(pixelPositionMatrixY < 1) = 0;
pixelPositionMatrixX(pixelPositionMatrixX < 1) = 0;
pixelPositionMatrixY(pixelPositionMatrixY > cameraResolution(1)) = 0;
pixelPositionMatrixX(pixelPositionMatrixX > cameraResolution(2)) = 0;

pixelIndexMatrixY = pixelPositionMatrixY;
pixelIndexMatrixX = pixelPositionMatrixX;

end

