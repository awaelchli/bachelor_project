% clear;
%% Parameters

Nlayers = 3;                            % Number of layers
layerDist = 4;
layerW = 100;                           % Width and height of layers in mm
layerH = layerW * (resolution(3) / resolution(4));
layerSize = [layerW, layerH];
totalLayerThickness = (Nlayers - 1) * layerDist;     % Height of layer stack
iterations = 20;                        % Maximum number of iterations in optimization process
outFolder = 'output/';                  % Output folder to store the layers
layerResolution = resolution([3, 4]);

% Testing
% cameraPlaneDistance = 1270;
% fov = deg2rad([90, 70]);
% focalLength = 10;
% distanceBetweenCameras = [1.25, 1.25] * 10;
% layerResolution = [150, 200];

%% Vectorize the light field
% Convert the 4D light field to a matrix of size [ prod(resolution), 3 ],
% and each column of this matrix represents a color channel of the light
% field
lightFieldVector = reshape(lightField, [], channels);

%% Compute the propagation matrix P
fprintf('\nComputing matrix P...\n');
tic;

P = computeMatrixP(Nlayers, ...
                   resolution, ...
                   layerResolution, ...
                   layerSize, ...
                   fov, ...
                   layerDist, ...
                   cameraPlaneDistance, ...
                   distanceBetweenCameras, ...
                   focalLength);

fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));

%% Convert to log light field

lightFieldVector(lightFieldVector < 0.01) = 0.01;
lightFieldVector = log(lightFieldVector);

%% Set the optimization constraints
tic;
ub = zeros(size(P, 2), 1); 
lb = zeros(size(P, 2), 1) + log(0.01);
x0 = zeros(size(P, 2), 1);
%% Run least squares optimization for each color channel

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
    layers(:, c) = sart(P, lightFieldVector(:, c), x0, lb, ub, iterations);
end

layers = exp(layers);
fprintf('Optimization took %i minutes.\n', floor(toc / 60));

%% Extract layers from optimization

layersR = squeeze(layers(:, 1));
layersG = squeeze(layers(:, 2));
layersB = squeeze(layers(:, 3));

% convert the layers from column vector to a matrix of dimension [Nlayers, height, width, channel]
layers = cat(2, layersR, layersG, layersB);
layers = reshape(layers, resolution(3), resolution(4), Nlayers, 3);

%% Save and display each layer
close all;

if(exist(outFolder, 'dir'))
    rmdir(outFolder, 's');
end
mkdir(outFolder);

printLayers(layers(:, :, 1:3, :), layerSize, outFolder, 'print1', 1);
% printLayers(layers(:, :, 4:5, :), layerSize, outFolder, 'print2', 4);

%% Reconstruct light field from attenuation layers and evaluate error

lightFieldRecVector = zeros(size(lightFieldVector));
lightFieldRecVector(:, 1) = P * log(layersR);
lightFieldRecVector(:, 2) = P * log(layersG);
lightFieldRecVector(:, 3) = P * log(layersB);

% convert the light field vector to the 4D light field
lightFieldRec = reshape(lightFieldRecVector, [resolution 3]);

lightFieldRec = exp(lightFieldRec);

center = floor([median(1:resolution(2)), median(1:resolution(1))]);
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

