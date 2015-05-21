function [layersRec lightFieldRec] = ...
    computeAttenuationLayersFromLightField4D(   lightField, lightFieldResolution, layerResolution, maxIters, minTransmission, ...
                                                tomographyMode, solver)                                              
                                            
    if nargin == 0
        error('computeAttenuationLayersFromLightField4D only works with all parameters!');    
    end    
                                            
	% declare matrix a global variable to save memory and time!
    global T;                 
                                                    
    % check if system is under-determined
    if prod(layerResolution) > prod(lightFieldResolution)
        error('Optimization is under-determined! This is not supported!');
    end    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set desired solution, constraints etc according to the current mode
    
    % no zeros in the light field - bad things happen in log-space!
    lightField(lightField<eps) = eps;
    
    % Sparse matrix for preconditioning.
    % This matrix is a required input for the solver;
    % preconditioning is not really being used in this example
    Jinfo = speye(prod(lightFieldResolution), prod(layerResolution));
    
    % attenuation layers with linear solution in log-space
    if (tomographyMode == 1) && ( (solver==0) || (solver==1) )
        
        % light field to log light field
        lightField = log(lightField);       
        
        % here, the optimization needs to be constrained to transmission values
        % between minTransmission and 1, so the log values need to be < 0
        lb      = zeros([prod(layerResolution) 1]) + log(minTransmission);
        ub      = zeros([prod(layerResolution) 1]);
        
        % initial guess - use either zeros or the backprojected solution (zeros
        % seem to work much better)
        layersRec = zeros(layerResolution)-log(eps);
        
        % use sparse matrix instead of function handles
        fun = @(Jinfo,Y,flag) projectLayersMatrix( Y, flag );    
        
        % set optmimization options
        options = optimset( 'Display', 'final', 'MaxIter', maxIters, 'JacobMult', fun); 
    
    % attenuation layers with non-linear solution
    elseif (tomographyMode == 1) && ( (solver==2) || (solver==3) )                
        
        % initial guess
        bInitialGuessRandom = false;
        if bInitialGuessRandom
            layersRec = rand(layerResolution);
            layersRec(layersRec<minTransmission) = minTransmission+eps;
        else
            % initial guess is just zero
            layersRec = zeros(layerResolution)-log(eps);    
            
            % constraints for lsqlin
            lb      = zeros([prod(layerResolution) 1]) + log(minTransmission);
            ub      = zeros([prod(layerResolution) 1]);
            
            % use sparse matrix instead of function handles
            fun = @(Jinfo,Y,flag) projectLayersMatrix( Y, flag );               
            % set optmimization options
            options = optimset( 'Display', 'final', 'MaxIter', maxIters, 'JacobMult', fun);
            % run lsqlin
            disp('Computing initial guess with lsqlin');
            [layersRec,resnorm,residual,exitflag,output] = ...
                lsqlin(Jinfo, log(lightField(:)), [],[],[],[],lb,ub,layersRec(:),options); 
            layersRec = exp(layersRec);            
            resnorm
            exitflag
            output
            disp('done, now computing final result with lsqnonlin');
        end
        
        % lower and upper bounds for lsqnonlin
        lb      = zeros([prod(layerResolution) 1]) + minTransmission;
        ub      = ones( [prod(layerResolution) 1]);
        
    % polarization field with lsqlin
    elseif (tomographyMode == 2) && ( (solver==0) || (solver==1) )
        
        % light field to polarization field
        lightField = asin( sqrt(lightField) );              
        
        % here, the optimization needs to be constrained to polarization
        % rotation values between 0 and pi/2 
        lb      = zeros([prod(layerResolution) 1]);
        ub      = zeros([prod(layerResolution) 1]) + pi/2;
        
        % initial guess is just zero
        layersRec = zeros(layerResolution);    
        
        % use sparse matrix instead of function handles
        fun = @(Jinfo,Y,flag) projectLayersMatrix( Y, flag );    
        
        % set optmimization options
        options = optimset( 'Display', 'final', 'MaxIter', maxIters, 'JacobMult', fun); 
        
    % polarization field with non-linear solver
    elseif (tomographyMode == 2) && ( (solver==2) || (solver==3) )                 
        
        % here, the optimization needs to be constrained to polarization
        % rotation values between 0 and pi/2 
        lb      = zeros([prod(layerResolution) 1]);
        ub      = zeros([prod(layerResolution) 1]) + pi/2;
        
        % initial guess - 0 doesn't work at all, random doesn't work very
        % well
        bInitialGuessRandom = false;
        if bInitialGuessRandom
            layersRec = rand(layerResolution) .* (pi/2); 
        % use lsqlin to compute initial guess
        else
            % initial guess is just zero
            layersRec = zeros(layerResolution);            
            % use sparse matrix instead of function handles
            fun = @(Jinfo,Y,flag) projectLayersMatrix( Y, flag );               
            % set optmimization options
            options = optimset( 'Display', 'final', 'MaxIter', maxIters, 'JacobMult', fun);
            % run lsqlin
            disp('Computing initial guess with lsqlin');
            [layersRec,resnorm,residual,exitflag,output] = ...
                lsqlin(Jinfo,asin( sqrt(lightField(:)) ),[],[],[],[],lb,ub,layersRec(:),options); 
            resnorm
            exitflag
            output
            disp('done, now computing final result with lsqnonlin');
        end
        

    % invalid options
    else
        error('Invalid combination of tomographyMode and solver!');
    end
    
    % check if everything is finite
    if sum(~isfinite(lightField(:))) > 0
        error('(Log) Light Field is not Finite!');
    end        
        
                
    % lsqlin
    if solver==0       
        
        [layersRec,resnorm,residual,exitflag,output] = ...
            lsqlin(Jinfo,lightField(:),[],[],[],[],lb,ub,layersRec(:),options);  
        resnorm
        exitflag
        output
        
        if output.iterations < maxIters-1
            disp(['  stopped after ' num2str(output.iterations) ' iters, of ' num2str(maxIters) ' max']);
        end
        
        % compute reconstructed light field
        lightFieldRec = fun([], layersRec, 1);
        
    % SART
    elseif solver==1        
        
        % function handle
        Afun = @(x,flag) projectLayersMatrix( x, flag );    
        % run SART
        layersRec = SART(Afun,lightField(:),lb,ub,layersRec(:),maxIters);  
        
        % compute reconstructed light field
        lightFieldRec = fun([], layersRec, 1); 
        
    % lsqnonlin (currently only works for polarization fields)
    elseif solver==2
        
        % attenuation layers
        if tomographyMode == 1       
            
            % non-linear error function, also computes the Jacobian info
            fun = @(X) errorFunctionAndComputeJacobianInfoAttenuationLSQNONLIN(X, lightField(:), layerResolution);
            % evaluate Jacobian instead of diretly computing the matrix
            jacobMult = @(J,Y,flag) evaluateAttenuationJacobianLSQNONLIN( J, Y, flag, layerResolution );             
                                
        % polarization field
        elseif tomographyMode == 2
            % non-linear error function, also computes the Jacobian info
            fun = @(X) errorFunctionAndComputeJacobianInfoPolarizationLSQNONLIN(X, lightField(:));
            % evaluate Jacobian instead of diretly computing the matrix
            jacobMult = @(J,Y,flag) evaluatePolarizationJacobianLSQNONLIN( J, Y, flag );            
        else
            error(['LSQNONLIN does not support tomographyMode ' num2str(tomographyMode)]);
        end
        
        
        % set optmimization options XXX
        options = optimset( 'Display', 'final', 'MaxIter', maxIters, ...
                            'Jacobian','on', 'JacobMult', jacobMult, ...
                            'DerivativeCheck', 'off'); 
                       
        % run lsqnonlin
        [layersRec,resnorm,residual,exitflag,output] = ...
            lsqnonlin(fun, layersRec(:), lb(:), ub(:), options); 
        resnorm
        exitflag
        output
        
        % compute reconstructed light field
        if tomographyMode == 1  
            lightFieldRec = T*log(layersRec);           
        elseif tomographyMode == 2 
            lightFieldRec = T*layersRec;           
        end                    
        
    % fmincon (currently only works for polarization fields)
    elseif solver==3
        
        error('fmincon is not supported yet!');
        
        %if tomographyMode ~= 2
        %    error('fmincon only works with tomography mode 2!');
        %end
        
        % function that returns sum of squares error and gradient
        fun = @(x) evaluateNonLinearErrorFunctionFMINCON( x, lightField(:) );
        
        % function that computes matrix-vector product with hessian
        hessFun = @(x,lambda,v) evaluateHessianFMINCON(x,v);
        
        % set optmimization options
        options = optimset( 'Display', 'final', 'MaxIter', maxIters, ...
                            'GradObj','on', 'DerivativeCheck', 'off',...
                            'Algorithm','interior-point',...
                            'SubproblemAlgorithm','cg', 'Hessian','user-supplied', 'HessFcn', hessFun);         
        
        % run fmincon
        [layersRec,resnorm,exitflag,output] = ...
            fmincon(fun,layersRec(:),[],[],[],[],lb(:),ub(:),[],options);
    
        % compute reconstructed light field
        lightFieldRec = T*layersRec;
    end   
    
%      exitflag
%      output.message     

    % reshape result    
    lightFieldRec   = reshape(lightFieldRec, lightFieldResolution);
    layersRec       = reshape(layersRec, layerResolution);  
    
    if tomographyMode == 1
        % exponentiate reconstruction
        lightFieldRec   = exp(lightFieldRec);   
        
        if (solver==0) || (solver==1)
            layersRec   = exp(layersRec); 
        end
        
    elseif tomographyMode == 2
        % convert from polarization field to light field and normalize
        % layers
        lightFieldRec   = sin(lightFieldRec).^2;                
        layersRec       = layersRec ./ (pi/2);  
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use explicit matrix (sparse)

function result = projectLayersMatrix( Y, flag )    
    % declare T a global variable
    global T;

    % forward projection
    if flag > 0                  
        result = T*Y;                                       
    % back-projection
    elseif flag < 0 
          result = T'*Y;                                                                                                         
    % forward and then back-projection
    else
      result = T'*(T*Y);        
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error function for lsqnonlin - attenuation

function [F, J] = errorFunctionAndComputeJacobianInfoAttenuationLSQNONLIN( x, targetLightField, layerResolution )

	% declare T a global variable
    global T;
    
    % Jacobian
    J = log(x);
    
    % light field error
    F = targetLightField - exp(T*J);
    
    % Jacobian - note:  need to return a vector here, otherwise matlab
    %                   crashes at the end!
    if nargout > 1                   
        % return Jacobian information in J        
        %J = reshape(J, layerResolution);
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jacobian multiply function for lsqnonlin - attenuation

function result = evaluateAttenuationJacobianLSQNONLIN( Jinfo, Y, flag, layerResolution )

    % declare T a global variable
    global T;
    
    Jinfo = reshape(Jinfo, layerResolution);

    % forward projection (seems to work)    
    if flag > 0   
        
        % initialize result
        result = zeros([size(T,1) size(Y,2)]);
        
        % for all incoming vectors
        for n=1:size(Y,2)        
            % for all layers
            for k=1:layerResolution(3)

                % set current layer to 0
                l = Jinfo; l(:,:,k) = 0;
                                
                % set everything but current layer to zeros
                x = reshape(Y(:,n), layerResolution);
                for k2=1:layerResolution(3)
                    if k2~=k
                        x(:,:,k2) = 0;
                    end
                end                
                
                % increment result
                result(:,n) = result(:,n) - ( (T*x(:)) .* exp(T*l(:)) );
                
            end            
        end
                                
    % back-projection
    elseif flag < 0           
        
        % initialize result
        result = zeros([size(T,2) size(Y,2)]);
        
        % for all incoming vectors
        for n=1:size(Y,2)                  
         
            % for all layers
            for k=1:layerResolution(3)
                
                % set current layer to 0
                l = Jinfo; l(:,:,k) = 0;
                
                % intermediate result
                currentResult = reshape( T' * (exp(T*l(:)) .* Y(:,n)), layerResolution);
                for k2=1:layerResolution(3)
                    if k2~=k
                        currentResult(:,:,k2) = 0;
                    end
                end 
                
                % increment end result
                result(:,n) = result(:,n) - currentResult(:);
                
            end
        end
                        
    % forward and then back-projection
    else
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % forward projection
        
        % intermediate result
        forwardResult = zeros([size(T,1) size(Y,2)]);        
        % for all incoming vectors
        for n=1:size(Y,2)        
            % for all layers
            for k=1:layerResolution(3)

                % set current layer to 0
                l = Jinfo; l(:,:,k) = 0;
                                
                % set everything but current layer to zeros
                x = reshape(Y(:,n), layerResolution);
                for k2=1:layerResolution(3)
                    if k2~=k
                        x(:,:,k2) = 0;
                    end
                end                
                
                % increment result
                forwardResult(:,n) = forwardResult(:,n) - ( (T*x(:)) .* exp(T*l(:)) );                
            end            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % back projection
        
        % initialize result
        result = zeros([size(T,2) size(Y,2)]);
        
        % for all incoming vectors
        for n=1:size(Y,2)                  
         
            % for all layers
            for k=1:layerResolution(3)
                
                % set current layer to 0
                l = Jinfo; l(:,:,k) = 0;
                
                % intermediate result
                currentResult = reshape( T' * (exp(T*l(:)) .* forwardResult(:,n)), layerResolution);
                for k2=1:layerResolution(3)
                    if k2~=k
                        currentResult(:,:,k2) = 0;
                    end
                end 
                
                % increment end result
                result(:,n) = result(:,n) - currentResult(:);
                
            end
        end
        
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error function for lsqnonlin - polarization

function [F, J] = errorFunctionAndComputeJacobianInfoPolarizationLSQNONLIN( x, targetLightField )

	% declare T a global variable
    global T;

    % polarization field
    P = T*x;
    
    % light field error
    F = targetLightField - sin(P).^2;
    
    % Jacobian
    if nargout > 1        
        % return Jacobian information in J        
        J = -2.*sin(P).*cos(P);  
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jacobian multiply function for lsqnonlin - polarization

function result = evaluatePolarizationJacobianLSQNONLIN( Jinfo, Y, flag )

    % declare T a global variable
    global T;

    % forward projection
    
    if flag > 0   
        result = repmat(Jinfo, [1 size(Y,2)]) .* (T*Y);
                                
    % back-projection
    elseif flag < 0         
        result = T' * (repmat(Jinfo, [1 size(Y,2)]).*Y);
                        
    % forward and then back-projection
    else                
        result = T' * (repmat(Jinfo, [1 size(Y,2)]).^2 .* (T*Y));
        
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error function for fmincon

function [F G] = evaluateNonLinearErrorFunctionFMINCON( x, targetLightField )

	% declare T a global variable
    global T;

    % polarization field
    F = T*x;
    
    % Jacobian information
    J = -2.*sin(F).*cos(F); 
    
    % light field error
    F = targetLightField - sin(F).^2;
           
    % compute gradient by multiplying with Jacobian
    G = 2 .* T' * (J.*F);
    
    % norm
    F = sum(F.^2);    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute matrix-vector product of Hessian at x with incoming vector v

function result = evaluateHessianFMINCON(x,v)
    error('To be implemented!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





