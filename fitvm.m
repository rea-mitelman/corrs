% FITVM         fit a von-mises distribution to data.
%
% call          [ X, R2, P, CI ] = FITVM( Y, X, MODE, STR, ALPHA, GRAPHICS )
%
% gets          Y           data vector or structure with fields 'data',
%                               'ymean', 'ysem'
%               X           data vector or sturcute with fields 'data', 'xmean'
%               MODE        {1}     unimodal vm distribution; non-linear fitting
%                           2       bimodal VM distribution
%                           3       unimodal, simplex algorithm
%                           4       unimodal, constrained non-linear
%               ALPHA       of confidence limits for fitted parameters
%               GRAPHICS    flag {0}
%
% returns       X, CI       the fitted parameters and their confidence
%               R2, P       of fitting
%
% calls         COMP_RS, FITFUNC 
%
% called by     AXE_TITLE, LINCIRC, PREP_FIT, PREH_SUA.

% 04-feb-04 ES

% 07-feb-04 Nelder Mead added (unconstrained)
% 08-feb-04 some modifications
% 09-mar-04 i/o

function [ x, R2, p, ci ] = fitvm( Y, X, mode, str, alpha, graphics )

% arguments

nargs = nargin;
if nargs < 1 | isempty ( Y )
    error( '1 argument' )
end
if isstruct( Y )
    ydata = Y.ydata;
else
    ydata = Y;
end
if nargs < 2 | isempty( X )
    X = [1/6 0 5/6:-1/6:1/3]'*2*pi;
end
if isstruct( X )
    xdata = X.xdata;
else
    xdata = X;
end
if nargs < 3 | isempty( mode )
    mode = 1;
end
if nargs < 4 | isempty( str )
    str = '';
end
if nargs < 5 | isempty( alpha )
    alpha = 0.05;
end
if nargs < 6 | isempty( graphics )
    graphics = 0;
end
ci = [];
xdata = xdata(:);
ydata = ydata(:);
if ~isequal( size( xdata ), size( ydata ) )
    error( 'unput size mismatch' )
end
global NicePlot
if ~isempty( NicePlot ) & NicePlot
    TFS = 12;
    XYFS = 10;
else
    TFS = 10;
    XYFS = 8;
end

% function fitting

[ ign phi0 ] = comp_rs( xdata, ydata );
dc0 = mean( ydata );
if mode == 1                % unimodal, lsqcurvefit
    LB = zeros( 1, 4 );
    [ x err res R2 p ci ] = fitfunc( xdata, ydata...
        , @vmf, [ dc0 1 phi0 1 ]...
        ,[],[],[],LB,[],[],alpha );
elseif mode == 2
    LB = zeros( 1, 6 );     % bimodal, lsqcurvefit
    [ x err res R2 p ] = fitfunc( xdata, ydata...
        , @vm2f, [ 1 phi0 1 0 0 1 ]...
        ,[],[],[],LB,[],[],alpha );
elseif mode == 3
    LB = zeros( 1, 4 );     % unimodal, nelder mead
    [ x err res R2 p ] = fitfunc( xdata, ydata...
        , [ @vmf @calc_err_vmf ], [ dc0 1 phi0 1 ]...
        ,[],[],[],LB,[],'simplex', alpha );
elseif mode == 4
    LB = zeros( 1, 4 );     % unimodal, constrained
    [ x err res R2 p ] = fitfunc( xdata, ydata...
        , [ @vmf @calc_err_vmf ], [ dc0 1 phi0 1 ]...
        ,[],[],[],LB,[],'constrained', alpha );
end

% graphics

if graphics > 0
    if graphics ~= 1
        subplot( graphics )
    else
        figure
    end
    %my_polar( xdata, ydata, '.-b' ); hold on, my_polar( xdata, vmf( x, xdata ), '.-r' );
%    lincirc( xdata, ydata, [], '.' ), hold on, lincirc( xdata, vmf( x, xdata ), [], '.-r' )
    if isstruct( X ) & isstruct( Y )
        lincirc( X.xmean, Y.ymean, Y.ysem, '.' ); hold on, lincirc( X.xmean, vmf( x, X.xmean ), [], '.-r' );
        legend( '', 'ydata', '', 'yest' )
    else
        lincirc( xdata, ydata, [], 'o' ); hold on, lincirc( xdata, vmf( x, xdata ), [], '.-r' );
    end
    tstr = sprintf( '%sR2 = %0.3g; p = %0.3g', str, R2, p );
    axe_title( tstr, [], [], TFS, XYFS );

    legend( 'ydata', 'yest' )
    xlabel( sprintf( '%s\n%s\n%s', num2str( ci(1,: ) ), num2str( x ), num2str( ci(2,: ) )  ) )
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
L = load( 'w:\diana\02nov02\osf\stable\sua_osf1.mat' )
SEP = repmat( '*', 1, 80 );
graphics = 1;
alpha = 0.05;
i = 0;
X = {}; R = {}; P = {};
Phat = []; Rhat = [];
for u = L.CHS(1:2)
    i = i + 1;
    x = []; r = []; p = [];
    fprintf( 1, '%s\nunit %d\n', SEP, L.CHS(i) );
    for obj = 1 : 2
        for e = 1 : 7
            tstr = slash_( sprintf( '%s, epoch %d, obj %d: ', unum2str( L.CHS(i), 'osf' ), e, obj ) );
            [ x( e, :, obj ) r( obj, e ) p( obj, e ) ] = fitvm( L.res(i).mx(:,e,obj), [], 1, tstr, alpha, graphics ); 
        end
    end
    X{ i } = x;
    R{ i } = r;
    P{ i } = p;
    Rhat = [ Rhat; r ];
    Phat = [ Phat; p ];
end

figure, subplot( 3,1,1 ), hist( Phat(:) ), axe_title( 'P', [], [], 12, 10 );
subplot( 3,1,2 ), hist( Rhat(:) ), axe_title( 'R2', [], [], 12, 10 );
subplot( 3,1,3 ), plot( Phat(:), Rhat(:), '.' )
[ cmat xbins ybins ] = bin_2d( Phat(:), Rhat(:), 10, 10 );
imagesc( xbins, ybins, cmat / sum( sum( cmat ) ) ), axis xy, %colormap( flipud( gray ) )
axe_title( '', [], [], 12, 10 );
xlabel( 'p' ), ylabel( 'R2' )
my_colorbar( 'horiz' )
sum( Phat(:) <= 0.05 & Rhat(:) >= 0.7 ) / prod( size( Rhat ) )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 10-mar-04

load w:\diana\02nov02\osf\stable\sua_osf1.mat
theta = [1/6 0 5/6:-1/6:1/3]'*2*pi;
theta2 = 0 : 0.1 : 2 * pi;

%for i = 1 : 60, 
for i = 9 : 16, 
    clf, 
%    YLIM = [ 0 dmax( max( max( res(i).mx( :, e, : ) ) ), [], 5 ) ];
    for obj = 1 : 2
        subplot( 2, 1, obj )
        % original data
        lincirc( theta, res(i).mx( :, e,obj ), res(i).sem(:,e,obj) ,'-b' ); 
        hold on, 
        % VM fit on all data
        lincirc( theta2, vmf( res(i).vmf(1:4,e,obj), theta2 ), [] ,'-r' ); 
        % VM fit on means
        [ x0 r2 p ] = fitvm( res(i).mx( :, e,obj ), theta );
        lincirc( theta2, vmf( x0, theta2 ), [] ,'-m' ); 
        YLIM( obj, : ) = ylim;
%        title( sprintf( '%s; %0.3g, %0.3g', slash_( unum2str( CHS( i ), 'osf' ) ), res(i).vmf(5,e,obj), res(i).vmf(6,e,obj) ) );
        title( sprintf( '%s; %0.3g, %0.3g; %0.3g, %0.3g', muscles{ i - 8 }, res(i).vmf(5,e,obj), res(i).vmf(6,e,obj), r2, p ) );
    end
    YLIMmax = [ 0 max( YLIM( :, 2 ) ) ];
    for obj = 1 : 2
        subplot( 2, 1, obj )
        ylim( YLIMmax );
    end
    pause, 
end









% to compare fits based on all data points to those based on means
for i = 1 : 60
    for obj = 1 : 2
        for e = 1 : 7
            fprintf( 1, 'doing %d, obj %d, epoch %d\n', i, obj, e )
            [ x0 r2 p ] = fitvm( res(i).mx( :, e,obj ), theta );
            VMF( :, e, obj ) = [ x0 r2 p ]';
            VMF_all( :, e, obj ) = res(i).vmf( :, e,obj );
            tmp( i ) = struct( 'tc', VMF, 'all', VMF_all );
        end
    end
end

% to look at scaling results
figure, 
plot( res(i).mx_s( :, e, 1 ), res(i).mx_s( :, e, 2 ), '.r' ), 
hold on, 
plot( res(i).mx( :, e, 1 ), res(i).mx( :, e, 2 ), '.' ), 
lsline, 
legend( 'scaled', 'orig' )
axis equal
lims = [ min( [ xlim; ylim ], [], 1 ) max( [ xlim; ylim ], [], 1 ) ];
lh = line( lims( [ 1 4 ] ), lims( [ 1 4 ] ) );
set( lh, 'Color', [ 0 0 0 ] );
