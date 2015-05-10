function [ layerPositionMatrixY, ...
           layerPositionMatrixX ] = computePixelPositionsOnLayer( layerResolution, ...
                                                                  layerSize )
% lengths in mm
% arrays: [Y, X] 

pixelSize = layerSize ./ layerResolution;

[ layerPositionMatrixY, layerPositionMatrixX ] = computeCenteredGridPositions(layerResolution, pixelSize);

end

