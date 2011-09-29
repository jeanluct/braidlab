function l = loopcoords(b,conv)
%LOOPCOORDS   Loop coordinates of a braid.
%   L = LOOPCOORDS(B) returns the Dynnikov loop coordinates of a braid, as
%   defined by Dehornoy.  The are defined by the action of a braid on a
%   nested generating set for the fundamental group of the disk with n
%   punctures.
%
%   L = LOOPCOORDS(B,CONV) controls the convetion whether the boundary is
%   added to the left (CONV='left') or right (CONV='right').  The default
%   is right, but Dehornoy's convention is on the left.
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

% Note that we use -b.word to compute the loop coordinates, which converts
% our generators to counterclockwise, to agree with Dehornoy's coordinates.

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
 case 'right'
  % Nested generators of the fundamental group, anchored to an extra
  % puncture on the right.
  u(n1+1:2*n1) = -1;
  % No need to convert sigmas.
  w = b.word;
end

if exist('vpi') == 2
  % Use variable precision integers if available.
  % Improve by checking for overflow first to see if needed, since vpi is
  % slooooow.  Maybe even print warning.
  l = braidlab.loopsigma(-w,vpi(u));
else
  l = braidlab.loopsigma(-w,u);
end
