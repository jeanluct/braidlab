function l = loopcoords(b,conv,typ)
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
%   Example: consider the braid of Dehornoy's Example 3.15:
%
%   >> b=braid([1 -2 1 2 1 3 -1 -2 -1 -2 -1 2 2 -3 -2]);
%   >> b.loopcoords('dehornoy')  % use Dehornoy's convention
%
%   ans = 
%
%   (( 1 -6  1 -7  4 -1 ))
%
%   This is the same as Dehornoy's (1,-7,-6,4,1,-1,0,8), since the last two
%   numbers can be dropped, and his notation is (a1,b1,a2,b2,a3,b3) compared
%   to our (a1,a2,a3,b1,b2,b3).
%
%   Reference: P. Dehornoy, "Efficient solutions to the braid isotopy
%   problem," Discrete Applied Mathematics 156 (2008), 3091-3112.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.EQ, LOOP.

if nargin < 2
  conv = 'right';
end

if isempty(conv)
  conv = 'right';
end

if nargin < 3
  typ = 'int64';
end

switch lower(typ)
 case 'int32'
  htyp = @int32;
  checkoverflow = true;
 case 'int64'
  htyp = @int64;
  checkoverflow = true;
 case 'double'
  htyp = @double;
  checkoverflow = false;
end

switch lower(conv)
 case {'left','dehornoy'}
  % Nested generators of the fundamental group, anchored to an extra
  % puncture on the left.
  n1 = b.n-1;
  l = braidlab.loop(zeros(1,n1),ones(1,n1));
  % Convert sigma_i to sigma_(i+1), to leave room for the puncture on the left.
  w = sign(b.word).*(abs(b.word)+1);
  if strcmpi(conv,'dehornoy'), w = -w; end % Dehornoy uses anticlockwise conv.
 case 'right'
  % Nested generators of the fundamental group, anchored to an extra
  % puncture on the right.
  l = braidlab.loop(b.n);
  % No need to convert sigmas.
  w = b.word;
end

l = braidlab.loop(loopsigma(w,htyp(l.coords)));

% Check for overflow/underflow.
% This doesn't seem very robust to me, but I can't find another way.
% The problem is that for matlab intmax+1 returns intmax, but intmax-1
% returns intmax as well.  So there is no simple way to know if the quantity
% overflowed but then was brought below intmax subsequently.  Would need
% to check for this in loopsigma itself.
if checkoverflow
  if ~any(l.coords == intmax(typ) | l.coords == intmin(typ))
    return
  end
else
  return
end

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
  warning('BRAIDLAB:braid:loopcoords:overflow', ...
          'Integer overflow... switching to double-precision.')
  l = braidlab.loopsigma(w,double(l.coords));
end
