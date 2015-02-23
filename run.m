clear;

%% Parameters
path = 'lightFields/messerschmitt/7x7x384x512/';
imageType = 'png';
resolution = [7, 7, 384, 512];      % Light Field resolution
fov = degtorad(10);                 % Field of View in radians
Nlayers = 5;                        % Number of layers
layerDist = 3;                      % Distance between layers in mm
layerW = 100;                       % Width and height of layers in mm
layerH = layerW * (resolution(3) / resolution(4));
layerSize = [layerW, layerH];
height = (Nlayers - 1) * layerDist; % Height of layer stack



%%
lightField = loadLightField(path, imageType, [resolution 3]);

% imshow(squeeze(lightField(2,3, :, :, :)));

lightField = log(lightField);

% Use red component only
Lred = lightField(:, :, :, :, 1);
% L represents the light field as a column vector
L = reshape(Lred, prod(resolution), 1);

tic;

%% Counting the number of non-zero elements in matrix
fprintf('Counting the number of non-zero elements in matrix...\n');
% nzCount = 47880922;
nzCount = 0;
for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        for pixelX = 1 : resolution(4)
            for pixelY = 1 : resolution(3)
                for layer = 1 : Nlayers
                    
                    [angleX, angleY] = computeRayAngles(imageX, imageY, fov, resolution([2, 1]));
                    [u, v] = pixelToSpaceCoordinates(pixelX, pixelY, resolution([4, 3]), layerSize);
                    intersection = [u, v] + (layer * layerDist - (height / 2)) * [angleX, angleY];
                    %intersectionP = floor(intersection .* resolution([4, 3]) ./ layerSize);
                    
                    if( all(intersection >= 0) && all(intersection < layerSize) )
                        % Increment non-zero element counter
                        nzCount = nzCount + 1;
                    end
                    
                end
            end
        end
    end
end

fprintf('Counting non-zero elements took %i seconds.\n', toc);

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

P = sparse(I, J, S, size(L, 1), prod([Nlayers resolution([3, 4])]), nzCount);
fprintf('Done calculating P. Calculation took %i seconds.\n', toc);

%% Run least squares optimization 
% not yet working
lb = zeros(size(P, 2), 1);                 % lower bound is zero
ub = ones(size(P, 2), 1) * inf;            % no upper bound
layers = lsqlin(P, [], [], [], [], [], lb, ub);

layers = reshape(layers, Nlayers, resolution(3), resolution(4));

imshow(squeeze(layers(1, :, :)));