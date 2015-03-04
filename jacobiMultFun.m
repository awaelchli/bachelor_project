function W = jacobiMultFun( P, Y, flag )
% Computes the Jacobian matrix product with Y. Here, P is the Jacobian
% matrix. This function is used as a function handle in the options of
% linear least squares optimization.

if(flag == 0)
    W = P' * (P * Y);
elseif(flag > 0)
    W = P * Y;
else
    W = P' * Y;
end


end

