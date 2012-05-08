% CIRC          plot a circle of radius r at (x,y).
%
% call          H = CIRC( X, Y, R, C, MC )
%
% GETS          X,Y         center; may be vectors of equal size
%               R           radius
%               C           circumference color {[1 1 1]}
%               MC          if specified, C is the filling color and MC is
%                           the circumference {[]}
%
% returns       H           handle to the plot.

% 09-aug-02 ES

% revisions
% 01-jan-02 empty circle if MC is empty
% 24-jan-04 use patch if MC is provided
% 05-sep-04 support of vector input

function h = circ(x,y,r,C,MC,linewidth);

nargs = nargin;
if nargs < 3, error( 'usage: circ( x, y, r )'), end
if nargs < 4 | isempty( C ), C = [1 1 1]; end
if nargs < 5 | isempty( MC ), MC = []; end

x = x( : );
y = y( : );
n = length( x );
if length( y ) ~= n, error( 'input size mismatch' ), end

if ~isnan( C )
    theta = ( 0 : 360 ) * pi / 180;
    nt = length( theta );
    x = x * ones( 1, nt ) + ones( n, 1 ) * r * cos( theta );
    y = y * ones( 1, nt ) + ones( n, 1 ) * r * sin( theta );
    if ~isempty( MC )
        for i = 1 : n
            h( i ) = patch( x( i, : ), y( i, : ), C );
%            h = patch( x + r * cos( theta ), y + r * sin( theta ), C );
            set( h( i ), 'EdgeColor', MC );
        end
    else
        x = [ x NaN * ones( n, 1 ) ]';
        y = [ y NaN * ones( n, 1 ) ]';
        h = line( x( : ), y( : ) );
%         h = line( x + r * cos( theta ), y + r * sin( theta ) );
        set( h, 'Color', C );
    end
end

return