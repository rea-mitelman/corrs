% VMF           DC + GAIN * 1 / (2*pi*I0(KAPPA)) * exp(KAPPA*cos(t-MYU)).
%
% call          F = VMF( X, XDATA )
%
% gets          X       [ DC GAIN MYU KAPPA ]
%               XDATA   angles (radians)
%
% returns       F       uni-modal Von-Mises distribution evaluated at the given angles.

% 04-feb-04 ES

function f = vmf( x, xdata )
f = x( 1 ) + x( 2 ) / ( 2 * pi * besseli( 0, x( 4 ) ) ) .* exp( x( 4 ) .* cos( xdata - x( 3 ) ) );
% no kappa normalization:
%f = x( 1 ) + x( 2 ) .* exp( x( 4 ) .* cos( xdata - x( 3 ) ) );
% no dc:
%f = x( 2 ) / ( 2 * pi * besseli( 0, x( 4 ) ) ) .* exp( x( 4 ) .* cos( xdata - x( 3 ) ) );  
return

calc_vm = inline( '1/(2*pi*besseli(0,kappa)).*exp(kappa.*cos(theta-myu))', 'theta', 'myu', 'kappa' );