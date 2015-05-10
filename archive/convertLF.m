function [ LF ] = convertLF( lightField, planeDist, fov, angularRes, spatialRes )
%  
%

resolution = size(lightField);
channels = resolution(5);
resolution = resolution(1 : 4);
distanceFromCamPlaneToSensorPlane = 20000; %In milimeters
% All sizes are in millimeters 

% resVirtualPlane = resolution([1, 2]);
% Dimension of the camera plane
% cPlane = cameraDist .* (resolution([1, 2]) - 1);
% Dimension of the virtual plane
resVirtualPlane = resolution([3, 4]);
layerSizeInMeter = [2000 2000];

% Camera indices
CindY = zeros(angularRes(1), spatialRes(1));
CindX = zeros(angularRes(2), spatialRes(2));
% Pixel indices
PindY = zeros(size(CindY));
PindX = zeros(size(CindX));

% the coordinate origin is at the center of the virtual plane
[posX, posY] = pixelToSpaceCoordinates(spatialRes([2, 1]), layerSizeInMeter);

% All possible angles
% Each angle is a relative angle, the tangent of the actual angle
% [anglesX, anglesY] = computeRayAngles(fov, resolution([3, 4]));
[anglesX, anglesY] = computeRayAngles(fov, angularRes);

anglesY = -anglesY;
anglesX = -anglesX;

shiftY = anglesY * planeDist;
shiftX = anglesX * planeDist;

% For every angle, compute the vertical and horizontal position on the
% camera plane
for iAngleY = 1 : angularRes(1)
    for iAngleX = 1 : angularRes(2)
        
        CindY(iAngleY, :) = posY + shiftY(iAngleY);
        CindX(iAngleX, :) = posX + shiftX(iAngleX);
        
    end
end

% cY = (CindY - min(CindY(:))) / (max(CindY(:)) - min(CindY(:)));
% imshow(cY);

% Shift to camera grid coordinate system
% y' = h/2 - y
% x' = x + w/2
% CindY = -CindY + cPlane(1) / 2;
% CindX = CindX + cPlane(2) / 2;

% cY = (CindY - min(CindY(:))) / (max(CindY(:)) - min(CindY(:)));
% imshow(cY);

%  
% CindY(CindY < 0) = 0;
% CindY(CindY > cPlane(1)) = 0;
% 
% CindX(CindX < 0) = 0;
% CindX(CindX > cPlane(2)) = 0;

% cY = (CindY - min(CindY(:))) / (max(CindY(:)) - min(CindY(:)));
% imshow(cY);

shiftY = anglesY * (planeDist - distanceFromCamPlaneToSensorPlane);
shiftX = anglesX * (planeDist - distanceFromCamPlaneToSensorPlane);

for iAngleY = 1 : angularRes(1)
    for iAngleX = 1 : angularRes(2)
        
        PindY(iAngleY, :) = (posY + shiftY(iAngleY)) - CindY(iAngleY, :);
        PindX(iAngleX, :) = (posX + shiftX(iAngleX)) - CindX(iAngleX, :);
        
    end
end

% figure(2);
% pY = (PindY - min(PindY(:))) / (max(PindY(:)) - min(PindY(:)));
% imshow(pY);

% PindY = -PindY + vPlane(1) / 2;
% PindX = PindX + vPlane(2) / 2;

% Scaling range
CindY = (CindY - min(CindY(:))) ./ (max(CindY(:)) - min(CindY(:))) * (resolution(1) - 1) + 1;
CindX = (CindX - min(CindX(:))) ./ (max(CindX(:)) - min(CindX(:))) * (resolution(2) - 1) + 1;
PindY = (PindY - min(PindY(:))) ./ (max(PindY(:)) - min(PindY(:))) * (resolution(3) - 1) + 1;
PindX = (PindX - min(PindX(:))) ./ (max(PindX(:)) - min(PindX(:))) * (resolution(4) - 1) + 1;

figure;
imshow(PindY, [])
figure;
imshow(PindX, [])

% CindY = repmat(CindY, 1, 1, resolution(4), resVirtualPlane(2)); % new arrangements : (thetaY, UY, thetaX, UX)
CindY = repmat(CindY, 1, 1, angularRes(2), spatialRes(2)); % new arrangements : (thetaY, UY, thetaX, UX)
% CindY = permute(CindY, [2, 4, 1, 3]);
CindY = permute(CindY, [1, 3, 2, 4]);
% CindY = permute(CindY, [3, 4, 1, 2]);
% size(CindY)
% CindX = repmat(CindX, 1, 1, resolution(3), resVirtualPlane(1)); % new arrangements : (thetaX, UX, thetaY, UY)
CindX = repmat(CindX, 1, 1, angularRes(1), spatialRes(1)); % new arrangements : (thetaX, UX, thetaY, UY)
CindX = permute(CindX, [3, 1, 4, 2]);
% size(CindX)

% PindY = repmat(PindY, 1, 1, resolution(4), resVirtualPlane(2)); % new arrangements : (thetaY, UY, thetaX, UX)
PindY = repmat(PindY, 1, 1, angularRes(2), spatialRes(2)); % new arrangements : (thetaY, UY, thetaX, UX)
PindY = permute(PindY, [1, 3, 2, 4]);
% size(PindY)
% PindX = repmat(PindX, 1, 1, resolution(3), resVirtualPlane(1)); % new arrangements : (thetaX, UX, thetaY, UY)
PindX = repmat(PindX, 1, 1, angularRes(1), spatialRes(1)); % new arrangements : (thetaX, UX, thetaY, UY)
PindX = permute(PindX, [3, 1, 4, 2]);
% size(PindX)

CindY = permute(CindY, [3, 4, 1, 2]);
CindX = permute(CindX, [3, 4, 1, 2]);
PindY = permute(PindY, [3, 4, 1, 2]);
PindX = permute(PindX, [3, 4, 1, 2]);

% LF = zeros(prod([resVirtualPlane resolution([3, 4])]), channels);
LF = zeros(prod([angularRes spatialRes]), channels);

% Interpolate for each channel
for c = 1 : channels
    fprintf(['Converting channel ' num2str(c) ' of ' num2str(channels) ' ...\n']);
    LF(:, c) = interpn(squeeze(lightField(:, :, :, :, c)), CindY(:), CindX(:), PindY(:), PindX(:));
end

% LF = reshape(LF, [resVirtualPlane resolution([3, 4]) channels]);
LF = reshape(LF, [angularRes spatialRes channels]);

for y = 1 : size(LF, 1)
    for x = 1 : size(LF, 2)
       LF(y, x, :, :, :) = rot90(squeeze(LF(y, x, :, :, :)), 2); 
    end
end

figure;
imshow(squeeze(LF(2, 2, :, :, :)));

% lightField = LF;

% %% Store the converted light field if desired
% out = 'tmp/';
% c = 1;
% for y = 1 : size(LF, 1)
%     for x = 1 : size(LF, 2)
%        imwrite(squeeze(LF(y, x, :, :, :)), [out num2str(c) '.png']);
%        c = c + 1;
%     end
% end

end
