function [ weightMatrix ] = computeRayIntersectionWeights( pixelIndexMatrixY, ...
                                                           pixelIndexMatrixX, ...
                                                           intersectionMatrixY, ...
                                                           intersectionMatrixX, ...
                                                           weightFunctionHandle )

% Weights are computed based on the deviation from the exact pixel
% location
                                                        
deviationY = intersectionMatrixY - pixelIndexMatrixY;
deviationX = intersectionMatrixX - pixelIndexMatrixX;

queryData = cat(3, deviationY, deviationX);
queryData = reshape(queryData, [], 2);

weightVector = weightFunctionHandle(queryData);
weightMatrix = reshape(weightVector, size(pixelIndexMatrixY));

end

