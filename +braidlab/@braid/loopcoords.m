function l = loopcoords(b,conv)
%LOOPCOORDS   Loop coordinates of a braid.
%   L = LOOPCOORDS(B) returns the Dynnikov loop coordinates of a braid, as
%   defined by Dehornoy.  The are defined by the action of a braid on a
%   nested generating set for the fundamental group of the disk with n
%   punctures.
%
%   L = LOOPCOORDS(B,CONV) controls the convetion whether the boundary
%   puncture is added to the right (CONV='right', the default) or left
%   (CONV='left').  If CONV='dehornoy', then generators are defined
%   anticlockwise with an extra puncture on the left, to agree with
%   Dehornoy's convention.
%
%   Note that the final (a(n),b(n)) pair of coordinates of Dehornoy's form
%   are redundant, so we drop them here.  In our convention we also list the
%   Dynnikov coordinates as (a(1),..,a(n-1),b(1),..,b(n-1)), rather than
%   (a(1),b(1),...,a(n-1),b(n-1)).
%
%   Reference: P. Dehornoy, "Efficient solutions to the braid isotopy
%   problem," Discrete Applied Mathematics 156 (2008), 3091-3112.
%
%   See also BRAID.

if nargin < 2
  conv = 'right';
end

% Add an extra puncture to the Dynnikov coordinates, corresponding to the
% boundary.
n1 = b.n-1; u = zeros(1,2*n1);

switch lower(conv)
 case {'left','dehornoy'}
  % Nested generators of the fundamental group, anchored to an extra
  % puncture on the left.
  u(n1+1:2*n1) = 1;
  % Convert sigma_i to sigma_(i+1), to leave room for the puncture on the left.
  w = sign(b.word).*(abs(b.word)+1);
  if strcmp(conv,'dehornoy'), w = -w; end % Dehornoy uses anticlockwise conv.
 case 'right'
  % Nested generators of the fundamental group, anchored to an extra
  % puncture on the right.
  u(n1+1:2*n1) = -1;
  % No need to convert sigmas.
  w = b.word;
end

l = braidlab.loopsigma(w,int64(u));

% Check for overflow/underflow.
% This doesn't seem very robust to me, but I can't find another way.
% The problem is that for matlab intmax+1 returns intmax, but intmax-1
% returns intmax as well.  So there is no simple way to know if the quantity
% overflowed but then was brought below intmax subsequently.  Would need
% to check for this in loopsigma itself.
if ~any(l == intmax('int64') | l == intmin('int64')), return; end

if exist('vpi') == 2
  % Use variable precision integers if available.
  % Improve by checking for overflow first to see if needed, since vpi is
  % slooooow.  Maybe even print warning.
  l = braidlab.loopsigma(w,vpi(u));
%elseif exist('fi') == 2
%  % Another option might be to use fi (fixed-point toolbox) with a
%  % specified large number of digits.
%  l = braidlab.loopsigma(w,sfi(u,120,0));
else
  warning('BRAIDLAB:braid:loopcoords', ...
	  'Integer overflow... switching to double-precision.')
  l = braidlab.loopsigma(w,u);
end
