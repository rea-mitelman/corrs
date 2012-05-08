% CALC_ERR_VMF           compute square error for VMF

% 07-feb-04 ES

function J = calc_err_vmf( x )
global xdat
global ydat
yhat = vmf( x, xdat );
J = norm( ydat - yhat ) .^ 2;
return
