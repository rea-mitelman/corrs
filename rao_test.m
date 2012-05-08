%   RAO_TEST        Rao's non-parametric test of uniformity for directional data.
%
%       call:   [H0 P_VALUE] = RAO_TEST(THETA, ALPHA)
%       does:   Test the null hypothesis (HO):
%                                               f(theta) = theta/(2*pi)
%               against the alternative (H1):
%                                               f(theta) != theta/(2*pi),
%       output: the p value; 1 if H0 is accepted, 0 if rejected.
%
%       See also RAO_TABLE.

% References:
% 1. 'An expanded table of probability values for Rao's Spacing Test',
% by Gerald S. Russell & Daniel J. Levitin, Communications in Statistics: Simulation
% and Computation, 24(4), 879-888, 1997, or web page
% http://ww2.mcgill.ca/psychology/levitin/AnExpand.htm;
% 2. 'Statistics of directional data', by K. V. Mardia, Academic Press, 1972.

% directional statistics package
% Dec-2001 ES

function [H0, p_value] = rao_test(theta, alpha);

nargs = nargin;
if nargs < 2 | isempty( alpha ), alpha = 0.05; end

% check input size
[s1 s2] = size(theta);
if s1~=1 & s2~=1
    error('input should be a vector')
end
% make it a row vector
if s1>s2
    theta = theta';
end
% check requested alpha
if alpha<=0 | alpha>=1
    error('alpha should be between 0 and 1')
end
% cannot estimate, likely to be non-uniform
if length(theta)<4
    H0 = 0;
    p_value = 1;
    return
end

% measure, sort and permute the input vector
n = length(theta);
theta = sort(theta);
ptheta = [theta(n) theta(1:(n-1))];

% find the arc lengths (incl. correction for circularity)
dtheta = theta - ptheta;
dtheta(1) = dtheta(1) + 2*pi;
%if 
%dtheta(1) = min([abs(theta(1) - theta(n)) abs(theta(n) - theta(1))])

% now dtheta holds the arc lengths.
% if theta distributes uniformly, these should be similar
% to the lengths obtained by slicing the circle into n arcs
lambda = 2*pi/n;

% the statistic - half the sum of the deviations
U = 1/2*sum(abs(dtheta-lambda));
p_value = rao_table(U*180/pi,n);
%U_statistic = U*180/pi

% compare
if p_value>alpha
    H0 = 1;
    tbuf = sprintf('H0 accepted (rao p value = %g)', p_value);
else
    H0 = 0;
    tbuf = sprintf('H0 rejected (rao p value = %g)', p_value);
end
