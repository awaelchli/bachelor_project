% run a number of SART updates 
function x = SART(Afun, b, lb, ub, x0, maxIters)
    
    % compute weights 
    W = Afun( ones(size(x0)) , 1); 
    W(W~=0) = 1 ./ W(W~=0);
    
    V = Afun( ones(size(W)) , -1); 
    V(V~=0) = 1 ./ V(V~=0);
    
    % initialize result
    x = x0;
    
    % run SART iterations
    for k=1:maxIters
        % update x
        x = x + V .* Afun( W .* (b-Afun(x,1)) , -1 );
        % project back into feasible range
        x(x<lb) = lb(x<lb); 
        x(x>ub) = ub(x>ub);
    end

end