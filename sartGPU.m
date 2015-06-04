function layers = sartGPU( P, l, x0, lb, ub, iterations )
%
%   SART - Simultaneous Algebraic Reconstruction Technique
%
%   P:              The propagation matrix
%   l:              The light field (vectorized)
%   x0:             The initial guess for the iterative reconstruction
%   lb, ub:         Upper and lower bounds for the layers
%   iterations:     The number of SART iterations to perform


% The weights for the updates: 
% Vector W contains the row-sums of P
% Vector V contains the column-sums of P

Pgpu = gpuArray(P);

W = Pgpu * gpuArray(ones(size(x0)));
W(W ~= 0) = 1 ./ W(W ~= 0);

V = Pgpu' * gpuArray(ones(size(W)));
V(V ~= 0) = 1 ./ V(V ~= 0);

% Start with initial guess
layers = gpuArray(x0);

for i = 1 : iterations
    
    % Perform SART update
    layers = layers + V .* (Pgpu' * ( W .* (l - Pgpu * layers)));
    
    % Clamp to desired range
    layers(layers < lb) = lb(layers < lb);
    layers(layers > ub) = ub(layers > ub);
end

layers = gather(layers);


end

