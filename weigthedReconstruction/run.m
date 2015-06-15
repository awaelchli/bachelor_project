% clear;
%% Parameters

inputFolder = 'lightFields/legotruck/legotruck_downsampled/';
load([inputFolder, 'lightField.mat']);

boxRadius = 0;

% Output folder to store the layers and evaluation data
outputFolder = 'output/';
% Indices of views for reconstruction and error evaluation
reconstructionIndices = [1, 1; 1, 3];
% Display reconstructions and error (true/false)
displayReconstruction = 1;
displayError = 1;
% Replication of the light field along given dimension (for visualization of 2D light fields)
replicationSizes = [1, 1, 1, 1, 1];
% Maximum number of iterations in optimization process
maxIterations = 20;
% Parameters for the weighting function on the layers
mu = [0, 0];
sigma = [ 0.3, 0;
          0, 0.3 ];
      
% weightFunctionHandle = @(data) mvnpdf(data, mu, sigma);
% weightFunctionHandle = @(data) tentWeightFunction(data, 1, 1);
weightFunctionHandle = @(data) ones(size(data, 1), 1);

%% Compute the propagation matrix P
fprintf('\nComputing matrix P...\n');
tic;

clear P resampledLightField lightFieldVector lightFieldVectorLogDomain layers layersLogDomain;

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

fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));

%% Vectorize the light field
% Convert the 4D light field to a matrix of size [ prod(resolution), channels ],
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

layersLogDomain = sart(P, lightFieldVectorLogDomain, x0, lb, ub, maxIterations);

layers = exp(layersLogDomain);
fprintf('Optimization took %i seconds.\n', floor(toc));

%% Extract layers from optimization

layers = permute(layers, [2, 1]);
layers = reshape(layers, [channels, layerResolution, NumberOfLayers]);
layers = permute(layers, [2, 3, 4, 1]);

%% Save and display each layer
close all;

if(exist(outputFolder, 'dir'))
    rmdir(outputFolder, 's');
end
mkdir(outputFolder);

printLayers(layers(:, :, 1 : NumberOfLayers, :), layerSize, outputFolder, 'print1', 1);
% show1DLayers(layers, 1);

%% Reconstruct light field from attenuation layers and evaluate error

reconstructLightField(P, resampledLightField, log(layers), reconstructionIndices, replicationSizes, displayReconstruction, displayError, outputFolder);
