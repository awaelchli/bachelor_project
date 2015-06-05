function [ gridPositionMatrixY, ...
           gridPositionMatrixX ] = computeCenteredGridPositions( gridResolution, ...
                                                                 gridStepSize)
% Input:        
%
%   gridResolution:         The resolution [Y, X] in Y- and X-direction of
%                           the grid to be generated
%   gridStepSize:           The size of the steps [Y, X] between the grid 
%                           points in Y- and X-direction


gridSize = (gridResolution - 1) .* gridStepSize;

positionsVectorY = gridSize(1) / 2 : -gridStepSize(1) : -gridSize(1) / 2;
positionsVectorX = -gridSize(2) / 2 : gridStepSize(2) : gridSize(2) / 2;


[ gridPositionMatrixY, gridPositionMatrixX ] = ndgrid(positionsVectorY, positionsVectorX);
% gridPositionMatrixY = repmat(positionsVectorY', 1, gridResolution(2));
% gridPositionMatrixX = repmat(positionsVectorX, gridResolution(1), 1);

end

