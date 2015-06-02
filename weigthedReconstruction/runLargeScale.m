% clear;
%% Parameters

NumberOfLayers = 5;
distanceBetweenLayers = 0.9;

% layerResolution = [100, 100 * aspectRatio];
% layerResolution = round(layerResolution);
layerResolution = lightFieldResolution([3, 4]);

layerWidth = 4 * aspectRatio;
layerHeight = 4;

boxRadius = 0;

% Maximum number of iterations in optimization process
maxIterations = 20;
% Output folder to store the layers
outFolder = 'output/';

% layerHeight = layerWidth * (lightFieldResolution(3) / lightFieldResolution(4));
layerSize = [layerWidth, layerHeight];
totalLayerThickness = (NumberOfLayers - 1) * distanceBetweenLayers;

% Indices of views for reconstruction and error evaluation
center = [2, 2];
custom = [3, 3];

mu = [0, 0];
sigma = [0.3 , 0;
         0, 0.3 ];
      
% weightFunctionHandle = @(data) mvnpdf(data, mu, sigma);
weightFunctionHandle = @(data) tentWeightFunction(data, 100, 1);
% weightFunctionHandle = @(data) ones(size(data, 1), 1);

%% Vectorize the light field
% Convert the 4D light field to a matrix of size [ prod(resolution), 3 ],
% and each column of this matrix represents a color channel of the light
% field

% lightFieldVector = reshape(lightField, [], channels);

%% Compute the propagation matrix P
fprintf('\nComputing matrix P...\n');
tic;
% 
[P, resampledLightField] = computeMatrixP_allLayerWeights(NumberOfLayers, ...
                   layerResolution, ...
                   layerSize, ...
                   distanceBetweenLayers, ...
                   cameraPlaneDistance, ...
                   distanceBetweenCameras, ...
                   weightFunctionHandle, ...
                   boxRadius, ...
                   lightField);
               
               
% P = computeMatrixP(NumberOfLayers, ...
%                    lightFieldResolution, ...
%                    layerResolution, ...
%                    layerSize, ...
%                    distanceBetweenLayers, ...
%                    cameraPlaneDistance, ...
%                    distanceBetweenCameras, ...
%                    weightFunctionHandle, ...
%                    boxFilterRadius);

lightFieldVector = reshape(resampledLightField, [], channels);

fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));


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

lightFieldRecVector = zeros(size(lightFieldVector));
lightFieldRecVector(:, 1) = P * log(layersR);
lightFieldRecVector(:, 2) = P * log(layersG);
lightFieldRecVector(:, 3) = P * log(layersB);

% convert the light field vector to the 4D light field
lightFieldRec = reshape(lightFieldRecVector, [lightFieldResolution 3]);

lightFieldRec = exp(lightFieldRec);

centerRec = squeeze(lightFieldRec(center(1), center(2), :, :, :));
centerLF = squeeze(lightField(center(1), center(2), :, :, :));
otherLF = squeeze(lightField(custom(1), custom(2), :, :, :));
customRec = squeeze(lightFieldRec(custom(1), custom(2), :, :, :));

% show the central and custom view from reconstruction
figure('Name', 'Light field reconstruction')
imshow(centerRec)
title('Central view');
imwrite(centerRec, [outFolder 'central_view_reconstruction' num2str(center(1)) '-' num2str(center(2)) '.png']);

figure('Name', 'Light field reconstruction')
imshow(customRec)
title('Custom view');
imwrite(customRec, [outFolder 'custom_view_reconstruction' num2str(custom(1)) '-' num2str(custom(2)) '.png']);

% show the absolute error
[error, mse] = meanSquaredErrorImage(centerRec, centerLF);
figure('Name', 'Absolute Error of Central View')
imshow(error, [])
title('Central view');

fprintf('RMSE for central view: %f \n', mse);

imwrite(error, [outFolder 'central_view_error.png']);

[error, mse] = meanSquaredErrorImage(customRec, otherLF);
figure('Name', 'Absolute Error of custom view')
imshow(error, [])
title('Custom view');

fprintf('RMSE for custom view: %f \n', mse);

imwrite(error, [outFolder 'custom_view_error.png']);