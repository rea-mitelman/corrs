% COMP_RS           Compute resultant vector - matrix version.
%
% call              R = COMP_RS( THETA, F )
%                   [ ..., PHI, AMP ] = COMP_RS
%
% gets              THETA       a vector of angles
%                   F           matrix of column vectors (amplitudes)
%
% returns           R           resultant, computed for each column separately
%                   PHI         mean direction (")
%                   AMP         amplitude at mean direction (")
%
% calls             nothing

% 02-aug-02 ES 

% revisions
% 26-aug-02 correction for zero columns
% 13-dec-03 compute the resultant's direction
% 29-jan-04 extension to sparse matrices of point data; amplitude returned
% 02-may-04 fixup (nans)
% 02-dec-04 matrix of THETA supported
% 12-jan-05 amplitude returned (line 63 remarked)
% 21-oct-05 IA NOTE: if there are NaNs in theta input, the R will be incorrect if F is not with NaNs in same locations      
%           For example if we give as input a sample of PDs, where NaNs are NS observations:       
%           comp_rs([pi/2 NaN pi/2],[1 1 1]') gives incorrect R 
%           comp_rs([pi/2 NaN pi/2],[1 NaN 1]') gives correct R
%           DIR_MEAN which returns 1-R, does not handle NaNs at all, so it's better to call COMP_RS 

function [ R, phi, amp ] = comp_rs(theta,f);

if nargin~=2, error('usage: comp_rs(theta,f)'), end
[rf cf] = size(f);
if ~issparse( theta ) & ( rf == 1 | cf == 1 )
    theta = theta(:);
end
[ rt ct ] = size(theta);
if issparse( theta )
    if cf ~= ct | ~issparse( f )
        error( 'input type | size mismatch' )
    end
    t = theta;
elseif prod( size( f ) ) ~= prod( size( theta ) )
    t = repmat(theta,1,cf);
else
    t = theta;
end
clear theta;

% n = sum(f);
% n(~n) = eps;
n = nansum(f);
n( isnan( n ) ) = eps;
n( ~n ) = eps;
x = f.*cos(t);
y = f.*sin(t);
sumx = nansum( x );
sumy = nansum( y );
C = sumx ./ n;
S = sumy ./ n;
R = (C.^2 + S.^2).^0.5;

if nargout > 1
    phi = mod( atan2(S,C), 2*pi );
end
if nargout > 2
    amp = ( sumx.^2 + sumy.^2 ) .^ 0.5;
    %amp = amp / rf;
end 

return