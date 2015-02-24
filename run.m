clear;

%% Parameters
path = 'lightFields/messerschmitt/7x7x384x512/';
imageType = 'png';
resolution = [7, 7, 384, 512];      % Light Field resolution
fov = degtorad(10);                 % Field of View in radians
Nlayers = 2;                        % Number of layers
layerDist = 3;                      % Distance between layers in mm
layerW = 100;                       % Width and height of layers in mm
layerH = layerW * (resolution(3) / resolution(4));
layerSize = [layerW, layerH];
height = (Nlayers - 1) * layerDist; % Height of layer stack

%% Loading the light field
lightField = loadLightField(path, imageType, [resolution 3]);

%% Counting the number of non-zero elements in matrix
tic;
fprintf('Counting the number of non-zero elements in matrix...\n');

nzCount = 0;
for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        for pixelX = 1 : resolution(4)
            for pixelY = 1 : resolution(3)
                for layer = 1 : Nlayers
                    
                    [angleX, angleY] = computeRayAngles(imageX, imageY, fov, resolution([2, 1]));
                    [u, v] = pixelToSpaceCoordinates(pixelX, pixelY, resolution([4, 3]), layerSize);
                    intersection = [u, v] + (layer * layerDist - (height / 2)) * [angleX, angleY];
                
                    if( all(intersection >= 0) && all(intersection < layerSize) )
                        % Increment non-zero element counter
                        nzCount = nzCount + 1;
                    end
                    
                end
            end
        end
    end
end

fprintf('Counting non-zero elements took %i minutes.\n', floor(toc / 60));

%% Computing index arrays for sparse matrix P
I = zeros(nzCount, 1);     % row indices
J = zeros(nzCount, 1);     % column indices  
S = ones(nzCount, 1);      % values

% index of the current non-zero element used in the for loop below.
index = 1;

fprintf('Computing matrix P...\n');
tic;
for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        for pixelX = 1 : resolution(4)
            for pixelY = 1 : resolution(3)
                
                % convert subscript indices to a linear index since L is
                % a column vector
                row = sub2ind(resolution, imageY, imageX, pixelY, pixelX);
                
                for layer = 1 : Nlayers
                    % compute if and where the ray penetrates the layer
                    [angleX, angleY] = computeRayAngles(imageX, imageY, fov, resolution([2, 1]));
                    [u, v] = pixelToSpaceCoordinates(pixelX, pixelY, resolution([4, 3]), layerSize);
                    intersection = [u, v] + (layer * layerDist - (height / 2)) * [angleX, angleY];
                    
                    % convert space coordinates to pixel coordinates
                    intersectionP = floor(intersection .* resolution([4, 3]) ./ layerSize);
                    
                    % check if intersection is out of bounds
                    if( all(intersection >= 0) && all(intersection < layerSize) )
                        % ray intersects with this layer
                        
                        col = sub2ind([Nlayers resolution([3, 4])], layer, intersectionP(2) + 1, intersectionP(1) + 1);
                        
                        I(index) = row;
                        J(index) = col;
                        index = index + 1;
                    end
                end
            end
        end
       	fprintf('Done with view %i:%i\n', imageX, imageY);
    end
end

P = sparse(I, J, S, prod(resolution), prod([Nlayers resolution([3, 4])]), nzCount);
fprintf('Done calculating P. Calculation took %i minutes.\n', floor(toc / 60));

%% Convert to log light field and separate rgb channels

lightField(lightField < eps) = eps;
lightField = log(lightField);

% RGB components of light field
Lr = lightField(:, :, :, :, 1);
Lg = lightField(:, :, :, :, 2);
Lb = lightField(:, :, :, :, 3);

% Convert the light field to a column vector for each channel
Lr = reshape(Lr, prod(resolution), 1);
Lg = reshape(Lg, prod(resolution), 1);
Lb = reshape(Lb, prod(resolution), 1);

%% Run least squares optimization for each color channel
lb = zeros(size(P, 2), 1) + log(0.001);
ub = zeros(size(P, 2), 1); 
options = optimset('Display', 'final', 'MaxIter', 15);

layersR = lsqlin(P, Lr, [], [], [], [], lb, ub, [], options);
layersG = lsqlin(P, Lg, [], [], [], [], lb, ub, [], options);
layersB = lsqlin(P, Lb, [], [], [], [], lb, ub, [], options);

layersR = reshape(layersR, Nlayers, resolution(3), resolution(4));
layersG = reshape(layersG, Nlayers, resolution(3), resolution(4));
layersB = reshape(layersB, Nlayers, resolution(3), resolution(4));

layersR = exp(layersR);
layersG = exp(layersG);
layersB = exp(layersB);

%% Display layers
for layer = 1 : Nlayers
    
    r = squeeze(layersR(layer, :, :));
    g = squeeze(layersG(layer, :, :));
    b = squeeze(layersB(layer, :, :));
    im = cat(3, r, g, b);
    subplot(1, Nlayers, layer), subimage(im);
end