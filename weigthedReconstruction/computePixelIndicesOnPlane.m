function [ pixelIndexMatrixY, ...
           pixelIndexMatrixX, ...
           positionsMatrixY, ...
           positionsMatrixX ] = computePixelIndicesOnPlane( positionsMatrixY, ...
                                                            positionsMatrixX, ...
                                                            planeResolution, ...
                                                            planeSize, ...
                                                            floorCeilOrRoundHandle )

                                                      
maxPositionY = planeSize(1) / 2;
maxPositionX = planeSize(2) / 2;

scalePositionToIndex = (planeResolution - 1) ./ planeSize;

% To 'screen' coordinate system
positionsMatrixY = maxPositionY - positionsMatrixY;
positionsMatrixX = positionsMatrixX + maxPositionX;

positionsMatrixY(positionsMatrixY < 0) = 0;
positionsMatrixX(positionsMatrixX < 0) = 0;
positionsMatrixY(positionsMatrixY > planeSize(1)) = 0;
positionsMatrixX(positionsMatrixX > planeSize(2)) = 0;

% Scale positions to the range [0, resolution - 1]
positionsMatrixY = scalePositionToIndex(1) .* positionsMatrixY;
positionsMatrixX = scalePositionToIndex(2) .* positionsMatrixX;

% Add one to the valid coordinates so that they are in range of [1, resolution]
positionsMatrixY(positionsMatrixY ~= 0) = positionsMatrixY(positionsMatrixY ~= 0) + 1;
positionsMatrixX(positionsMatrixX ~= 0) = positionsMatrixX(positionsMatrixX ~= 0) + 1;

pixelIndexMatrixY = floorCeilOrRoundHandle(positionsMatrixY);
pixelIndexMatrixX = floorCeilOrRoundHandle(positionsMatrixX);

end

