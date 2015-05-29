function [ weights ] = tentWeightFunction( data, maxY, maxX )

d = sqrt(data(:, 1).^2 + data(:, 2).^2);
slope = maxY / maxX;

weights = 1 - slope * d;

end

