function P = computeMatrixP( Nlayers, resolution, layerSize, originLF, originLayers, fov, cameraDist, layerDist )


% Computing index arrays for sparse matrix P

% upper bound for number of non-zero values in the matrix P
maxNonZeros = prod(resolution) * Nlayers; 

I = zeros(maxNonZeros, 1);      % row indices
J = zeros(maxNonZeros, 1);      % column indices  
S = ones(maxNonZeros, 1);       % values

% index of the current non-zero element used in the for loop below.
c = 1;

% 2D pixel positions (relative to one layer) in coordinates of the light field
% [posX, posY] = pixelToSpaceCoordinates(resolution([4, 3]), layerSize, originLF);
% The scale is 1 / pixelSize, it is used to go from space coordinates back to
% pixel indices
% scale = resolution([4, 3]) ./ layerSize;
scale = [1, 1];

[anglesX, anglesY] = computeRayAngles(fov, resolution([3, 4]));

for imageX = 1 : resolution(2)
    for imageY = 1 : resolution(1)
        
        % intersection points of rays with relative angles [angleX, angleY]
        % on the first layer (most bottom layer), can go outside of layer
        % boudaries
        posXL1 = (imageX - 1) * cameraDist(2) - (originLayers(3) - originLF(3)) .* anglesX;
        posYL1 = (imageY - 1) * cameraDist(1) - (originLayers(3) - originLF(3)) .* anglesY;
        
        for layer = 1 : Nlayers
            
            % shift intersection points according to current layer            
            posXCurrentLayer = posXL1 - (layer - 1) * layerDist .* anglesX;
            posYCurrentLayer = posYL1 - (layer - 1) * layerDist .* anglesY;
            
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

end

