% clear;
%% Parameters

NumberOfLayers = 5;
distanceBetweenLayers = 1;

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
reconstructionIndices = [1, 1; 3, 1; 2, 2; 3, 3];

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

clear P resampledLightField lightFieldVector lightFieldVectorLogDomain layers ...
      layersR layerG layerB lightFieldRecVector lightFieldRec;

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
% lightFieldVector = reshape(lightField, [], channels);

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
%     layers(:, c) = sartGPU(P, lightFieldVectorLogDomain(:, c), x0, lb, ub, maxIterations);
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

printLayers(layers(:, :, 1 : NumberOfLayers, :), layerSize, outFolder, 'print1', 1);
% printLayers(layers(:, :, 3, :), layerSize, outFolder, 'print2', 3);

%% Reconstruct light field from attenuation layers and evaluate error

reconstructLightField(P, resampledLightField, layers, reconstructionIndices, 1, 1, outFolder);
