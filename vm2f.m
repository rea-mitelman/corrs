% VM2F           DC + GAIN1 * VM( MYU1, KAPPA1 ) + GAIN2 * VM( MYU2, KAPPA2 ).
%
% call          F = VM2F( X, XDATA )
%
% gets          X       [ DC GAIN1 MYU1 KAPPA1 GAIN2 MYU2 KAPPA2 ]
%               XDATA   angles (radians)
%
% returns       F       bi-modal Von-Mises distribution evaluated at the given angles.

% 04-feb-04 ES

function f = vmf( x, xdata )
f = x( 1 ) / ( 2 * pi * besseli( 0, x( 3 ) ) ) .* exp( x( 3 ) .* cos( xdata - x( 2 ) ) )...
    + x( 4 ) / ( 2 * pi * besseli( 0, x( 6 ) ) ) .* exp( x( 6 ) .* cos( xdata - x( 5 ) ) );

% f = x( 2 ) / ( 2 * pi * besseli( 0, x( 4 ) ) ) .* exp( x( 4 ) .* cos( xdata - x( 3 ) ) )...
%     + x( 5 ) / ( 2 * pi * besseli( 0, x( 7 ) ) ) .* exp( x( 7 ) .* cos( xdata - x( 6 ) ) );

% f = x( 1 ) + x( 2 ) / ( 2 * pi * besseli( 0, x( 4 ) ) ) .* exp( x( 4 ) .* cos( xdata - x( 3 ) ) )...
%     + x( 5 ) / ( 2 * pi * besseli( 0, x( 7 ) ) ) .* exp( x( 7 ) .* cos( xdata - x( 6 ) ) );
return