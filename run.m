clear;

%% Parameters
path = '../lightFields/messerschmitt/7x7x384x512/';
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

P = zeros(size(L, 1), prod([Nlayers resolution([3, 4])]));
%alpha = zeros(prod([Nlayers resolution([3, 4])]), 1);

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
                    [u, v] = computePixelPosition(pixelX, pixelY, resolution([4, 3]), layerSize);
                    
                    intersection = [u, v] + (layer * layerDist - (height / 2)) * [angleX, angleY];
                    % convert space coordinates to pixel coordinates
                    intersectionP = floor(intersection * resolution([4, 3]) / layerSize);
                    % check if intersection is out of bounds
                    if( intersection >= 0 && intersection(1) < layerW && intersection(2) < layerH )
                        % ray intersects with this layer
                        col = sub2ind([Nlayers resolution([3, 4])], layer, intersection(2), intersection(1));
                        P(row, col) = 1;
                        display(layer);
                    end
                end
                
            end
        end
        
    end
    
    lb = zeros(size(P, 2));                 % lower bound is zero
    ub = ones(size(P, 2)) * inf;            % no upper bound
    layers = lsqlin(P, [], [], [], [], [], lb, ub);
    
    layers = reshape(layers, Nlayers, resolution(3), resolution(4));
    
    imshow(squeeze(layers(1, :, :)));
end
