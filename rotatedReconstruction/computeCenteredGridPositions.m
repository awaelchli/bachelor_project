function [ gridPositionMatrixY, ...
           gridPositionMatrixX ] = computeCenteredGridPositions( gridResolution, ...
                                                                 gridStepSize)
% arrays [Y, X]
% 

gridSize = (gridResolution - 1) .* gridStepSize;

positionsVectorY = gridSize(1) / 2 : -gridStepSize(1) : -gridSize(1) / 2;
positionsVectorX = -gridSize(2) / 2 : gridStepSize(2) : gridSize(2) / 2;

gridPositionMatrixY = repmat(positionsVectorY', 1, gridResolution(2));
gridPositionMatrixX = repmat(positionsVectorX, gridResolution(1), 1);

% gridPositionMatrixY
% gridPositionMatrixX

end

