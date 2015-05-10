% clear;
%% Parameters
% 
% NumberOfLayers = 3;
% distanceBetweenLayers = 100;
% cameraPlaneDistance = 1270;
% % fov = deg2rad([23.8, 18.6673]);
% distanceCameraPlaneToSensorPlane = 1270;
% % distanceBetweenCameras = [20, 20];
% % lightFieldResolution = [2, 2, 3, 3];
% % channels = 3;
% % lightField = lightField(:, :, 1 : 100, 1 : 100, :);
% % lightField = zeros([lightFieldResolution, 3]);
% layerResolution = [300, 300];
% layerWidth = 500;
% layerHeight = 500;
% 
% fov = [layerWidth/2 layerHeight/2] ./ distanceCameraPlaneToSensorPlane;
% fov = atan(fov)*2;


NumberOfLayers = 6;
distanceBetweenLayers = 0.5;
% cameraPlaneDistance = 2000;


% distanceBetweenCameras = [200, 200];
% lightFieldResolution = [2, 2, 3, 3];
% channels = 3;
% lightField = lightField(:, :, 1 : 100, 1 : 100, :);
% lightField = zeros([lightFieldResolution, 3]);
layerResolution = [300 * aspectRatio, 300];
layerWidth = 4 * aspectRatio;
layerHeight = 4;

% fov = [layerWidth/2 layerHeight/2] ./ distanceCameraPlaneToSensorPlane;
% fov = atan(fov)*2;

% Maximum number of iterations in optimization process
maxIterations = 20;
% Output folder to store the layers
outFolder = 'output/';

% layerHeight = layerWidth * (lightFieldResolution(3) / lightFieldResolution(4));
layerSize = [layerWidth, layerHeight];
totalLayerThickness = (NumberOfLayers - 1) * distanceBetweenLayers;

%% Vectorize the light field
% Convert the 4D light field to a matrix of size [ prod(resolution), 3 ],
% and each column of this matrix represents a color channel of the light
% field

% h = fspecial('gaussian', [5 5], 2);
% for camIndexY = 1 : size(lightField,1)
%     for camIndexX = 1 : size(lightField,2)
%         img = squeeze(lightField(camIndexY, camIndexX, :,:,:));
%         img = imfilter(img,h);
%         lightField(camIndexY, camIndexX, :,:,:) = img;
%     end
% end

% lightFieldVector = reshape(permute(lightField, [3, 4, 1, 2, 5]), [], channels);
lightFieldVector = reshape(lightField, [], channels);


%% Compute the propagation matrix P
fprintf('\nComputing matrix P...\n');
tic;

P = computeMatrixP(NumberOfLayers, ...
                   lightFieldResolution, ...
                   layerResolution, ...
                   layerSize, ...
                   fov, ...
                   distanceBetweenLayers, ...
                   cameraPlaneDistance, ...
                   distanceBetweenCameras, ...
                   distanceCameraPlaneToSensorPlane);

fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));

%% Trying to normalize the weights

% rowSum = sum(P, 2);
% for i = 1 : size(P, 1)
%     if(rowSum(i) ~= 0)
%         P(i, :) = P(i, :) ./ rowSum(i);
%     end
% end
% rowSums = sum(P,2);
% rowSums = max(1, rowSums);
% P = spdiags(1./rowSums,0,size(P,1),size(P,1))*P;

% colSums = sum(P,1);
% colSums = max(1, colSums);
% P = spdiags(1./colSums,0,size(P,1),size(P,1))*P;

%% Convert to log light field
lightFieldVectorLogDomain = lightFieldVector;
lightFieldVectorLogDomain(lightFieldVectorLogDomain < 0.01) = 0.01;
lightFieldVectorLogDomain = log(lightFieldVectorLogDomain);

%% Set the optimization constraints
tic;
ub = zeros(size(P, 2), 1); 
lb = zeros(size(P, 2), 1) + log(0.01);
x0 = zeros(size(P, 2), 1);
%% Run least squares optimization for each color channel
% 
% % The Jacobian matrix of Px - d is just P. 
% Id = speye(size(P));
% W = @(Jinfo, Y, flag) projection(P, Y , flag);
% 
% options = optimset('MaxIter', iterations, 'Jacobian', 'on', 'JacobMult', W, 'UseParallel', true);
% 
% layers = zeros(size(P, 2), 3);
% for c = 1 : channels
%     fprintf('Running optimization for color channel %i ...\n', c);
%     layers(:, c) = lsqlin(Id, lightFieldVector(:, c), [], [], [], [], lb, ub, x0, options);
% end

%% Solve using SART

layers = zeros(size(P, 2), 3);
for c = 1 : channels
    fprintf('Running optimization for color channel %i ...\n', c);
    layers(:, c) = sart(P, lightFieldVectorLogDomain(:, c), x0, lb, ub, maxIterations);
end

layers = exp(layers);
fprintf('Optimization took %i minutes.\n', floor(toc / 60));

%% Extract layers from optimization

layersR = squeeze(layers(:, 1));
layersG = squeeze(layers(:, 2));
layersB = squeeze(layers(:, 3));

% convert the layers from column vector to a matrix of dimension [Nlayers, height, width, channel]
layers = cat(2, layersR, layersG, layersB);
layers = reshape(layers, [ layerResolution, NumberOfLayers, 3]);

%% Save and display each layer
% close all;

if(exist(outFolder, 'dir'))
    rmdir(outFolder, 's');
end
mkdir(outFolder);

printLayers(layers(:, :, 1:NumberOfLayers, :), layerSize, outFolder, 'print1', 1);
% printLayers(layers(:, :, 3, :), layerSize, outFolder, 'print2', 3);

%% Reconstruct light field from attenuation layers and evaluate error

lightFieldRecVector = zeros(size(lightFieldVectorLogDomain));
lightFieldRecVector(:, 1) = P * log(layersR);
lightFieldRecVector(:, 2) = P * log(layersG);
lightFieldRecVector(:, 3) = P * log(layersB);

% lightFieldRec = permute(lightFieldRecVector, [3, 4, 1, 2, 5]);
% convert the light field vector to the 4D light field
lightFieldRec = reshape(lightFieldRecVector, [lightFieldResolution 3]);

lightFieldRec = exp(lightFieldRec);

% center = floor([median(1:lightFieldResolution(2)), median(1:lightFieldResolution(1))]);
center = [2, 2];
other = [3, 3];
centerRec = squeeze(lightFieldRec(center(1), center(2), :, :, :));
centerLF = squeeze(lightField(center(1), center(2), :, :, :));
otherLF = squeeze(lightField(other(1), other(2), :, :, :));
otherRec = squeeze(lightFieldRec(other(1), other(2), :, :, :));

% show the central and custom view from reconstruction
figure('Name', 'Light field reconstruction')
imshow(centerRec)
title('Central view');
imwrite(centerRec, [outFolder 'central_view.png']);

figure('Name', 'Light field reconstruction')
imshow(otherRec)
title('Custom view');

% show the absolute error
error = abs(centerRec - centerLF);
figure('Name', 'Absolute Error of Central View')
imshow(error)
title('Central view');

imwrite(error, [outFolder 'central_view_error.png']);

error = abs(otherRec - otherLF);
figure('Name', 'Absolute Error of custom view')
imshow(error)
title('Custom view');

imwrite(error, [outFolder 'custom_view_error.png']);

