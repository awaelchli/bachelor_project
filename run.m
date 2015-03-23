% clear;
%% Parameters
% Note: paths are relative to the current folder
%
% path = 'lightFields/messerschmitt/7x7x384x512/';
% path = 'lightFields/dice/';
% path = 'lightFields/dice/7x7x384x512_fov20/';
% path = 'lightFields/dragon/';
% path = 'lightFields/butterfly/7x7x384x512/';
% path = 'lightFields/rx_watch/';
path = 'lightFields/';
filename = 'img00001';                  % Used for h5 and lfr files
imageType = 'png';
resolution = [7, 7, 384, 512];          % Light field resolution
channels = 3;                           % Use 3 (color) or 1 (grayscale) channels
fov = degtorad(10);                     % Field of view in radians
Nlayers = 5;                            % Number of layers
layerDist = 4;
layerW = 100;                           % Width and height of layers in mm
layerH = layerW * (resolution(3) / resolution(4));
layerSize = [layerW, layerH];
height = (Nlayers - 1) * layerDist;     % Height of layer stack
iterations = 20;                        % Maximum number of iterations in optimization process
outFolder = 'output/';                  % Output folder to store the layers
originLayers = [0, 0, 0];               % origin of the attenuator, [x y z] in mm
originLF = [0, 0, -height / 2];         % origin of the light field, relative to the attenuator

%% Load the light field from a folder of images

% lightField = loadLightField(path, imageType, [resolution channels]);

%% Load the light field from a H5 file

% lightField = h5read([path filename '.h5'], '/LF');
% lightField = permute(lightField, [5, 4, 3, 2, 1]);
% lightField = double(lightField) / 255;
% resolution = size(lightField);
% resolution = resolution(1 : 4);
% layerH = layerW * (resolution(3) / resolution(4));
% layerSize = [layerW, layerH];
% % read required attributes 
% focalLength = h5readatt([path filename '.h5'], '/', 'focalLength');
% fov = degtorad(1 / focalLength);
% channels = h5readatt([path filename '.h5'], '/', 'channels');

%% Load the light field from a Lytro image

lytroPath = 'C:/Users/Adrian/AppData/Local/Lytro/cameras/';
whiteImageDatabasePath = fullfile(lytroPath, 'WhiteImageDatabase.mat');

LFUtilUnpackLytroArchive(lytroPath);
LFUtilProcessWhiteImages(lytroPath);
DecodeOptions = LFDefaultField('DecodeOptions', 'WhiteImageDatabasePath', whiteImageDatabasePath);
[lightField, metadata, ~] = LFLytroDecodeImage([path filename '.lfr'], DecodeOptions);

lightField = lightField(:, :, :, :, 1 : 3);
lightField = double(lightField);
resolution = size(lightField);
resolution = resolution(1 : 4);
layerH = layerW * (resolution(3) / resolution(4));
layerSize = [layerW, layerH];

%% Vectorize the light field
% Convert the 4D light field to a matrix of size [ prod(resolution), 3 ],
% and each column of this matrix represents a color channel of the light
% field

lightFieldVector = reshape(lightField, [], channels);

%% Computing index arrays for sparse matrix P
% upper bound for number of non-zero values in the matrix P
maxNonZeros = prod(resolution) * Nlayers; 

I = zeros(maxNonZeros, 1);      % row indices
J = zeros(maxNonZeros, 1);      % column indices  
S = ones(maxNonZeros, 1);       % values

% index of the current non-zero element used in the for loop below.
c = 1;

% 2D pixel positions (relative to one layer) in coordinates of the light field
[posX, posY] = pixelToSpaceCoordinates(resolution([4, 3]), layerSize, originLF);
% The scale is 1 / pixelSize, it is used to go from space coordinates back to
% pixel indices
scale = resolution([4, 3]) ./ layerSize;

fprintf('\nComputing matrix P...\n');
tic;

for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        
        % compute relative angles for incoming rays from current view
        [angleX, angleY] = computeRayAngles(imageX, imageY, fov, resolution([2, 1]));
       
        % intersection points of rays with relative angles [angleX, angleY]
        % on the first layer (most bottom layer), can go outside of layer
        % boudaries
        posXL1 = posX + (originLayers(3) - originLF(3)) * angleX;
        posYL1 = posY + (originLayers(3) - originLF(3)) * angleY;
        
        for layer = 1 : Nlayers
            
            % shift intersection points according to current layer
            posXCurrentLayer = posXL1 - (layer - 1) * layerDist * angleX;
            posYCurrentLayer = posYL1 - (layer - 1) * layerDist * angleY;
            
            % pixel indices 
            pixelsX = ceil(scale(1) * (posXCurrentLayer - originLayers(1)));
            pixelsY = ceil(scale(2) * (posYCurrentLayer - originLayers(2)));
            
            % pixels indices outside of bounds get removed
            pixelsX(pixelsX > resolution(4)) = 0;
            pixelsX(pixelsX < 1) = 0;
            pixelsY(pixelsY > resolution(3)) = 0;
            pixelsY(pixelsY < 1) = 0;
            
            % pick out the indices that are inside bounds
            indicesX = find(pixelsX);
            indicesY = find(pixelsY);
            
            % make as many copies of the X-indices as there are Y-indices
            indicesX = repmat(indicesX, numel(indicesY), 1);
            % make as many copies of the Y-indices as there are X-indices
            indicesY = repmat(indicesY', 1, size(indicesX, 2));
            
            % make copies of the image indices
            imageIndicesX = imageX + zeros(size(indicesX));
            imageIndicesY = imageY + zeros(size(indicesX));
            
            % convert the 4D subscipts to row indices all at once
            rows = sub2ind(resolution, imageIndicesY(:), imageIndicesX(:), indicesY(:), indicesX(:));
            
            % !!! Note: Here, light field resolution is the same as layer
            % resolution. Support for different light field and layer
            % resolution is currently not supported !!!
            layerIndices = layer + zeros(size(indicesX));
            
            pixelsX = pixelsX(pixelsX ~= 0);
            pixelsY = pixelsY(pixelsY ~= 0);
            indicesX = repmat(pixelsX, [numel(pixelsY) 1]);
            indicesY = repmat(pixelsY', [1 size(pixelsX,2)]);  
            
            % convert the subscripts to column indices
            columns = sub2ind([resolution([3, 4]) Nlayers], indicesY(:), indicesX(:), layerIndices(:));
             
            % insert the calculated indices into the sparse arrays
            numInsertions = numel(rows);
            I(c : c + numInsertions - 1) = rows;
            J(c : c + numInsertions - 1) = columns;
            
            c = c + numInsertions ;
        end
    end
end

P = sparse(I(1:c - 1), J(1:c - 1), S(1:c - 1), prod(resolution), prod([Nlayers resolution([3, 4])]), c - 1);
% save('P.mat', 'P');
fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));

%% Convert to log light field

lightFieldVector(lightFieldVector < 0.01) = 0.01;
lightFieldVector = log(lightFieldVector);

%% Run least squares optimization for each color channel
tic;
ub = zeros(size(P, 2), 1); 
lb = zeros(size(P, 2), 1) + log(0.01);
x0 = zeros(size(P, 2), 1);

% The Jacobian matrix of Px - d is just P. 
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
printLayers(layers(:, :, 4:5, :), layerSize, outFolder, 'print2', 4);

%% Reconstruct light field from attenuation layers and evaluate error

lightFieldRecVector = zeros(size(lightFieldVector));
lightFieldRecVector(:, 1) = P * log(layersR);
lightFieldRecVector(:, 2) = P * log(layersG);
lightFieldRecVector(:, 3) = P * log(layersB);

% convert the light field vector to the 4D light field
lightFieldRec = reshape(lightFieldRecVector, [resolution 3]);

lightFieldRec = exp(lightFieldRec);

center = [median(1:resolution(2)), median(1:resolution(1))];
other = [7, 7];
centerRec = squeeze(lightFieldRec(center(1), center(2), :, :, :));
centerLF = squeeze(lightField(center(1), center(2), :, :, :));
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

