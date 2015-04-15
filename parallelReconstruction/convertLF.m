% Convert a light field
% All sizes are in millimeters 

resVirtualPlane = resolution([3, 4]);
% layerRes = [96, 110];
% Dimension of the camera plane
cPlane = cameraDist .* (resolution([1, 2]) - 1);
% Dimension of the virtual plane
vPlane = [1000, 1000];

dimension = [resolution(3), resolution(4), resVirtualPlane(1), resVirtualPlane(2), channels];


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
[anglesX, anglesY] = computeRayAngles(fov, resVirtualPlane);

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

cY = (CindY - min(CindY(:))) / (max(CindY(:)) - min(CindY(:)));
imshow(cY);

% Shift to camera grid coordinate system
% y' = h/2 - y
% x' = x + w/2
CindY = -CindY + cPlane(1) / 2;
CindX = CindX + cPlane(2) / 2;

% cY = (CindY - min(CindY(:))) / (max(CindY(:)) - min(CindY(:)));
% imshow(cY);


CindY(CindY < 0) = 0;
CindY(CindY > cPlane(1)) = 0;

CindX(CindX < 0) = 0;
CindX(CindX > cPlane(2)) = 0;

cY = (CindY - min(CindY(:))) / (max(CindY(:)) - min(CindY(:)));
imshow(cY);


LF = interpn(lightField, CindY, CindX, PindY, PindX);