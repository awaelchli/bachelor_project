function W = projection( P, Y, flag )
%   P:              The projection/propagation matrix
%   Y:              The vector to be projected, either the light field or the
%                   layers
%   flag:           flag = 1: Project layers / compute emitted light field from layers  
%                   flag =-1: 

if(flag == 0)
    % Forward and backward projection
    W = P' * (P * Y);
elseif(flag > 0)
    % Forward projection
    W = P * Y;
else
    % Backward projection
    W = P' * Y;
end


end

