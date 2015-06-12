% clear;
%% Parameters

NumberOfLayers = 5;
distanceBetweenLayers = 1;
layerResolution = lightFieldResolution([3, 4]);

layerWidth = 4 * aspectRatio;
layerHeight = 4;
% layerWidth = 4;
% layerHeight = 0;

boxRadius = 0;

% Maximum number of iterations in optimization process
maxIterations = 20;
% Output folder to store the layers
outFolder = 'output/';

layerSize = [layerWidth, layerHeight];
totalLayerThickness = (NumberOfLayers - 1) * distanceBetweenLayers;

% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 1, 3];

% Parameters for the weighting function on the layers
mu = [0, 0];
sigma = [0.3 , 0;
         0, 0.3 ];
      
% weightFunctionHandle = @(data) mvnpdf(data, mu, sigma);
% weightFunctionHandle = @(data) tentWeightFunction(data, 1, 1);
weightFunctionHandle = @(data) ones(size(data, 1), 1);

%% Compute the propagation matrix P
fprintf('\nComputing matrix P...\n');
tic;

clear P resampledLightField lightFieldVector lightFieldVectorLogDomain layers;

[P, resampledLightField] = computeMatrixPForResampledLF(NumberOfLayers, ...
                                                        layerResolution, ...
                                                        layerSize, ...
                                                        distanceBetweenLayers, ...
                                                        cameraPlaneDistance, ...
                                                        distanceBetweenCameras, ...
                                                        weightFunctionHandle, ...
                                                        boxRadius, ...
                                                        lightField);
         
% rowSums = sum(P, 2);
% rowSums = max(0.00001, rowSums);
% P = spdiags(1 ./ rowSums, 0, size(P, 1), size(P,1)) * P;

% colSums = sum(P, 1);
% colSums = max(0.00001, colSums);
% P = P * spdiags(1 ./ colSums', 0, size(P, 2), size(P, 2));

fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));

%% Vectorize the light field
% Convert the 4D light field to a matrix of size [ prod(resolution), 3 ],
% and each column of this matrix represents a color channel of the light
% field
lightFieldVector = reshape(resampledLightField, [], channels);

%% Convert to log light field
lightFieldVectorLogDomain = lightFieldVector;
lightFieldVectorLogDomain(lightFieldVectorLogDomain < 0.01) = 0.01;
lightFieldVectorLogDomain = log(lightFieldVectorLogDomain);

%% Solve using SART
tic;
fprintf('Running optimization ...\n');

% Optimization constraints
ub = zeros(size(P, 2), channels); 
lb = zeros(size(P, 2), channels) + log(0.01);
x0 = zeros(size(P, 2), channels);

layers = sart(P, lightFieldVectorLogDomain, x0, lb, ub, maxIterations);

layers = exp(layers);
fprintf('Optimization took %i seconds.\n', floor(toc));

%% Extract layers from optimization

layers = permute(layers, [2, 1]);
layers = reshape(layers, [channels, layerResolution, NumberOfLayers]);
layers = permute(layers, [2, 3, 4, 1]);

%% Save and display each layer
close all;

if(exist(outFolder, 'dir'))
    rmdir(outFolder, 's');
end
mkdir(outFolder);

printLayers(layers(:, :, 1 : NumberOfLayers, :), layerSize, outFolder, 'print1', 1);
% show1DLayers( layers, 1 );

%% Reconstruct light field from attenuation layers and evaluate error

reconstructLightField(P, resampledLightField, log(layers), reconstructionIndices, 1, 1, outFolder);
