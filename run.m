clear;
%% Parameters
%path = 'lightFields/messerschmitt/7x7x384x512/';
path = 'lightFields/dice/';
imageType = 'png';
resolution = [7, 7, 384, 512];          % Light field resolution
fov = degtorad(10);                     % Field of view in radians
lightFieldSize = [100, 75];
Nlayers = 5;                            % Number of layers
layerDist = 2;                          % Distance between layers in mm
layerW = 100;                           % Width and height of layers in mm
layerH = layerW * (resolution(3) / resolution(4));
layerSize = [layerW, layerH];
height = (Nlayers - 1) * layerDist;     % Height of layer stack
outFolder = 'output/';                  % Output folder to store the layers

%% Loading the light field
lightField = loadLightField(path, imageType, [resolution 3]);

% lightField = lightField(3:5, 3:5, :, :, :);
% r = size(lightField);
% resolution = r(1:4);

%% Computing index arrays for sparse matrix P
% upper bound for number of non-zero values in the matrix P
maxNonZeros = prod(resolution) * Nlayers; 

I = zeros(maxNonZeros, 1);   % row indices
J = zeros(maxNonZeros, 1);      % column indices  
S = ones(maxNonZeros, 1);       % values

% index of the current non-zero element used in the for loop below.
index = 0;

lightFieldVector = zeros(prod(resolution), 3);

fprintf('Computing matrix P...\n');
tic;
for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        
        % compute angles for incoming rays from current view
        [angleX, angleY] = computeRayAngles(imageX, imageY, fov, resolution([2, 1]));
        fprintf('angleX: %i, ', angleX);
        fprintf('angleY: %i \n', angleY);
        
        for pixelX = 1 : resolution(4)
            for pixelY = 1 : resolution(3)
                
                % convert subscript indices to a linear index since L is
                % a column vector
                
%                 row = sub2ind(resolution, imageY, imageX, pixelY, pixelX);
                row = ((imageY - 1) * resolution(2) + imageX - 1) * resolution(3) * resolution(4) + ...
                       (pixelY - 1) * resolution(4) + pixelX;
                   
                lightFieldVector(row, :) = lightField(imageY, imageX, pixelY, pixelX, :);
                
                [u, v] = pixelToSpaceCoordinates(pixelX, pixelY, resolution([4, 3]), layerSize);
                
                for layer = 1 : Nlayers
                    % compute if and where the ray penetrates the layer
                    intersection = [u, v] + ((layer - 1) * layerDist - (height / 2)) * [angleX, angleY];
                    % rayPositionsX = lightFieldPixelCentersX - lightFieldOrigin(3)*vx + layerOrigin(3)*vx;
                    % convert space coordinates to pixel coordinates
                    intersectionP = ceil(intersection .* resolution([4, 3]) ./ layerSize);
                    % check if intersection is out of bounds
                    if( all(intersection >= 0) && all(intersection < layerSize) )
                        % ray intersects with this layer
%                         fprintf('hit\n');
%                         col = sub2ind([Nlayers resolution([3, 4])], layer, intersectionP(2) + 1, intersectionP(1) + 1);
                        col = (layer - 1) * resolution(3) * resolution(4) + (intersectionP(2) - 1) * resolution(4) + intersectionP(1);
                        
                        index = index + 1;
                        I(index) = row;
                        J(index) = col;
%                     else
%                         fprintf('miss\n');
                    end
                end
            end
        end
       	fprintf('Done with view %i:%i\n', imageX, imageY);
    end
end

P = sparse(I(1:index), J(1:index), S(1:index), prod(resolution), prod([Nlayers resolution([3, 4])]), index);
save('P.mat', 'P');
fprintf('Done calculating P. Calculation took %i minutes.\n', floor(toc / 60));

%% Convert to log light field and separate rgb channels
% lightField(lightField < 0.01) = 0.01;
% lightField = log(lightField);
% 
% % RGB components of light field
% Lr = lightField(:, :, :, :, 1);
% Lg = lightField(:, :, :, :, 2);
% Lb = lightField(:, :, :, :, 3);
% 
% % Convert the light field to a column vector for each channel
% Lr = reshape(Lr, prod(resolution), 1);
% Lg = reshape(Lg, prod(resolution), 1);
% Lb = reshape(Lb, prod(resolution), 1);

lightFieldVector(lightFieldVector < 0.01) = 0.01;
lightFieldVector = log(lightFieldVector);

%% Run least squares optimization for each color channel
tic;
lb = zeros(size(P, 2), 1) + log(0.01);
ub = zeros(size(P, 2), 1); 
% lb = zeros(size(P, 2), 1);
% ub = ones(size(P, 2), 1);
options = optimset('Display', 'iter', 'MaxIter', 10);

layersR = lsqlin(P, lightFieldVector(:, 1), [], [], [], [], lb, ub, [], options);
layersG = lsqlin(P, lightFieldVector(:, 2), [], [], [], [], lb, ub, [], options);
layersB = lsqlin(P, lightFieldVector(:, 3), [], [], [], [], lb, ub, [], options);

% layersR = lsqlin(P, Lr, [], [], [], [], lb, ub, [], options);
% layersG = lsqlin(P, Lg, [], [], [], [], lb, ub, [], options);
% layersB = lsqlin(P, Lb, [], [], [], [], lb, ub, [], options);

fprintf('Optimization took %i minutes.\n', floor(toc / 60));
% 
% layersR = reshape(layersR, Nlayers, resolution(3), resolution(4));
% layersG = reshape(layersG, Nlayers, resolution(3), resolution(4));
% layersB = reshape(layersB, Nlayers, resolution(3), resolution(4));

%% Extract layers from optimization

layersR = exp(layersR);
layersG = exp(layersG);
layersB = exp(layersB);

layers = zeros(Nlayers, resolution(3), resolution(4), 3);

for layer = 1 : Nlayers
    for y = 1 : resolution(3)
        for x = 1 : resolution(4)
            % convert layer-pixel coordinates to linear index
            idx = (layer - 1) * resolution(3) * resolution(4) + (y - 1) * resolution(4) + x;
            r = layersR(idx);
            g = layersG(idx);
            b = layersB(idx);
            layers(layer, y, x, :) = [r g b];
        end
    end
end

%% Save and display each layer
close all;

layerSize = [180, 180 * (resolution(3) / resolution(4))];

for layer = 1 : Nlayers
%     r = squeeze(layersR(layer, :, :));
%     g = squeeze(layersG(layer, :, :));
%     b = squeeze(layersB(layer, :, :));
%     im = cat(3, r, g, b);
    im = cat(3, squeeze(layers(layer, :, :, :)));
    % add padding to image
    padding = 20;
    im = padarray(im, [padding, padding], 1);
    pixelSize = layerSize ./ [resolution(4) resolution(3)];
    w = size(im, 2);
    h = size(im, 1);
%     printSize = layerSize - 2 * padding * pixelSize;
    printSize = layerSize;
    % insert markers that help for alignment
    offset = 10;
    pos = [offset offset; 
           w - offset offset; 
           offset h - offset];  
    im = insertMarker(im, pos, 'Color', 'Black', 'Size', 10);
    % insert layer number
    im = insertText(im, [w - offset h - offset], layer, ...
                    'AnchorPoint', 'Center', 'BoxOpacity', 0);
    % save images and print to pdf
    if(~exist(outFolder, 'dir'))
        mkdir(outFolder);
    end
    imwrite(im, [outFolder num2str(layer) '.png']);
    printToPDF(im, printSize, [outFolder num2str(layer) '.pdf']);
end

%% Reconstruct light field from attenuation layers and evaluate error

lightFieldRecVector = zeros(size(lightFieldVector));
lightFieldRecVector(:, 1) =  P * log(layersR);
lightFieldRecVector(:, 2) =  P * log(layersG);
lightFieldRecVector(:, 3) =  P * log(layersB);

% convert the light field vector to the 4D light field
lightFieldRec = permute(reshape(lightFieldRecVector, [resolution([4, 3, 2, 1]) 3]), [4, 3, 2, 1, 5]);

lightFieldRec = exp(lightFieldRec);

% show the central view
figure('Name', 'Light field reconstruction')
imshow(squeeze(lightFieldRec(median(1:resolution(2)), median(1:resolution(1)), :, :, :)))
title('Central view');