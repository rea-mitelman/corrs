% FITFUNC           fit data (training, test set) to function.
%
%                   X = FITFUNC(XDATA,YDATA,FUN,X0)
%
%                   wrapper for MATLAB's lsqcurvefit.
%
%                   [X, ERR, RES] = FITFUNC(...,XTEST,YTEST)
%
%                   tests the function fitted by the data set on the test 
%                   set and return error (norm of test fit minus norm of train fit)
%                   and norm of residue (of test fit).
%
%                   [ ..., R2, P, CI ] = FITFUNC(...,STR,LB,UB,METHOD,ALPHA,GRAPHICS)
%
%                   (with or without output arguments) 
%                   enables choice of lower and upper bounds for the
%                   function fitting, as well as method ('lsq', 'simplex',
%                   or 'constrained'). confidence bounds of 1-ALPHA are computed.
%                   then we plot the results with the string in STR as title.

% 27-mar-03 ES

% revisions
% 04-feb-04 R2,p,LB,UB added
% 07-fev-04 R2,p computations local; choice of algorithm permitted
% 08-feb-04 confidence limits for the training data added
% 17-feb-04 output calculations
% 08-mar-04 i/o
% 11-mar-04 use simple R2; maxiters -> 500
% 14-mar-04 fix R2 for Tss = 0

% note - prediction bounds are not computed

function [ x, err, res, R2, p, ci ] = fitfunc(xdata,ydata,fun,x0,xtest,ytest,str,LB,UB,method,alpha,graphics)

nargs = nargin;
nout = nargout;
if nargs<4, error('4 arguments'), end
if nargs<5, xtest = []; end
if nargs<6, xtest = []; end
if nargs<7 | isempty(str), str = ''; end
if nargs < 8 | isempty( LB ), LB = []; end
if nargs < 9 | isempty( UB ), UB = []; end
if nargs < 10 | isempty( method ), method = 'lsq'; end
if nargs < 11 | isempty( alpha ), alpha = 0.05; end
if nargs < 12 | isempty( graphics ), graphics = 0; end

% optimset
if graphics, DISPLAYOPT = 'on';
else, DISPLAYOPT = 'off'; end
MAXFE = 1e9;
MAXIT = 500;
opts = optimset('MaxFunEvals',MAXFE,'MaxIter',MAXIT,'Display',DISPLAYOPT);

[xdata xi] = sort(xdata);
ydata = ydata(xi);
n = length( xdata );
m = length( x0 );
dof = n - m;

switch method
    case 'lsq'          % supports bounds
        [ x ign1 ign2 ign3 output ign4 J ] = lsqcurvefit(fun,x0,xdata,ydata,LB,UB,opts);
    case 'simplex'      % 'best' method for unconstrained, unbounded fitting
        global xdat
        global ydat
        xdat = xdata;
        ydat = ydata;
        [ x, ign1, ign2, output ] = fminsearch(fun(2),x0);
        J = [];
    case 'constrained'  % support bounds and multiple contraints
        [ x, ign1, ign2, output ] = fmincon( fun(2), x0, [], [], [], [], LB, UB );
        J = [];
end
iters = output.iterations;
funcs = output.funcCount;

% compute residuals and sum of squares
if nout>1 | ismember(1,graphics) | ( (~isempty(xtest) & ~isempty(ytest)) )
    yest = feval(fun,x,xdata);
    residual = yest - ydata;
    Ess = norm( residual ) .^ 2;
end

if nout > 3
    Rss = norm( yest - mean( ydata ) ) .^ 2;
    Tss = norm( ydata - mean( ydata ) ) .^ 2;
    R2 = 1 - Ess / Tss;
    F = Rss / Ess * ( n - 2 );
    p = 1 - fcdf( F, 1, n - 2 );
    if isinf( R2 ), R2 = NaN; end
    % adjusted R2
%    R2 = 1 - Ess / Tss * ( n - 1 ) / ( dof - 1 );
    
    % confidence limits
    if ~isempty( J ) & nout > 5
        % mean square error
        mse = Ess / dof;
        % qr decompose the jacobian
        [ Q R ] = qr( J, 0 );
        rinv = R \ eye( length( R ) );
        % ci = b +- t * sqrt( s )
        % where b are the estimated coefficients
        %       t is the inverse of the cumulative t distribution
        %       s is the diagonal of inv(X'X)*mse in the linear case
        s = sum( rinv.^2, 2 ) * mse;
        t = -tinv(alpha/2,dof);
        cb = t * sqrt( s(:).' );
        ci = [ x - cb; x + cb ];
    end
end

if (~isempty(xtest) & ~isempty(ytest))
    yest_test = feval(fun,x,xtest);
    res = norm(yest_test-ytest) .^ 2;
    err = res - norm(yest-ydata) .^ 2;
else
    res = [];
    err = [];
end

if ismember(1,graphics)
    
    figure
    subplot(2,2,1)
    %pdot(xdata,ydata,'.'); hold on, plot(xdata,yest,'r');
    plot(xdata,ydata,'.-b',xdata,yest,'.-r')
    nx = length(x);
    if str, eval(['axe_title(sprintf(' str '));']);
    else axe_title;
    end
    %set(gca,'ylim',[-1 1])
    legend( 'ydata', 'yest' )
    xlabel( num2str( x ) )
    if nargout > 3
        ystr = sprintf( 'R2 = %0.3g; p = %0.3g', R2, p );
        ylabel( ystr )
    end
    YLIM = ylim;
    set( gca, 'ylim', [ 0 YLIM( 2 ) ] );
    
    subplot(2,2,3)
    %pdot(xdata,yest-ydata);
    plot(xdata,yest-ydata,'-.k')  % = residual
    axe_title(sprintf(...
        'train set: residual\nnorm = %0.3g; %d iterations'...
        , Ess, iters));
    lh = line(get(gca,'xlim'),[0 0]); set(lh,'color',[1 0 0])
    %set(gca,'ylim',[-1 1])
    
    if ~isempty(xtest) & ~isempty(ytest)
        subplot(2,2,2)
        pdot(xtest,ytest,'.'); hold on, plot(xtest,yest_test,'r');%plot(xtest,ytest,'.',xtest,yest_test,'r')
        axe_title(sprintf('test set: %d dp',length(xtest)));
        %plot(xtest,yest_test+SE,'g',xtest,yest_test-SE,'g')
        set(gca,'ylim',[-1 1])
        
        subplot(2,2,4)
        pdot(xtest,yest_test-ytest);  % = residual
        axe_title(sprintf('test set: residual\nnorm = %0.3g'...
            ,norm(yest_test-ytest).^2));
        lh = line(get(gca,'xlim'),[0 0]); set(lh,'color',[1 0 0])
        set(gca,'ylim',[-1 1])
    end
    
end

return
