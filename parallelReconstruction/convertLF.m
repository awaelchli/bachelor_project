% Convert a light field
% All sizes are in millimeters 



planeDist = 2;


resVirtualPlane = resolution([1, 2]);
% Dimension of the camera plane
cPlane = cameraDist .* (resolution([1, 2]) - 1);
% Dimension of the virtual plane
vPlane = [1000, 1000];

% Camera indices
CindY = zeros(resolution(3), resVirtualPlane(1));
CindX = zeros(resolution(4), resVirtualPlane(2));
% Pixel indices
PindY = zeros(size(CindY));
PindX = zeros(size(CindX));

% the coordinate origin is at the center of the virtual plane
originShift = - vPlane([2, 1]) / 2;
[posX, posY] = pixelToSpaceCoordinates(resVirtualPlane([2, 1]), vPlane, originShift);

% All possible angles
% Each angle is a relative angle, the tangent of the actual angle
[anglesX, anglesY] = computeRayAngles(fov, resolution([3, 4]));

anglesY = -anglesY;
anglesX = -anglesX;

shiftY = anglesY * planeDist;
shiftX = anglesX * planeDist;

% For every angle, compute the vertical and horizontal position on the
% camera plane
for iAngleY = 1 : resolution(3)
    for iAngleX = 1 : resolution(4)
        
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

shiftY = anglesY * -planeDist;
shiftX = anglesX * -planeDist;

for iAngleY = 1 : resolution(3)
    for iAngleX = 1 : resolution(4)
        
        PindY(iAngleY, :) = CindY(iAngleY, :) - (posY + shiftY(iAngleY));
        PindX(iAngleX, :) = CindX(iAngleX, :) - (posX + shiftX(iAngleX));
        
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

CindY = repmat(CindY, 1, 1, resolution(4), resVirtualPlane(2));
CindY = permute(CindY, [2, 4, 1, 3]);
size(CindY)
CindX = repmat(CindX, 1, 1, resolution(3), resVirtualPlane(1));
CindX = permute(CindX, [2, 4, 3, 1]);
size(CindX)

PindY = repmat(PindY, 1, 1, resolution(4), resVirtualPlane(2));
PindY = permute(PindY, [2, 4, 1, 3]);
size(PindY)
PindX = repmat(PindX, 1, 1, resolution(3), resVirtualPlane(1));
PindX = permute(PindX, [4, 2, 3, 1]);
size(PindX)

LF = zeros(prod([resVirtualPlane resolution([3, 4])]), channels);

for c = 1 : channels
    fprintf(['Converting channel ' num2str(c) ' of ' num2str(channels) ' ...\n']);
    LF(:, c) = interpn(squeeze(lightField(:, :, :, :, c)), CindY(:), CindX(:), PindY(:), PindX(:));
end

LF = reshape(LF, [resVirtualPlane resolution([3, 4]) channels]);

for y = 1 : size(LF, 1)
    for x = 1 : size(LF, 2)
       LF(y, x, :, :, :) = rot90(squeeze(LF(y, x, :, :, :)), 2); 
    end
end

figure;
imshow(squeeze(LF(1, 1, :, :, :)));
