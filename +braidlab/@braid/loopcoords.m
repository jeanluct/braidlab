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
%   L = LOOPCOORDS(B,CONV,'TYPE') or LOOPCOORDS(B,CONV,@TYPE) creates a loop
%   with coordinates of type TYPE.  The default is TYPE=int64.  Other useful
%   values are double, int32, and vpi (variable precision integers).  Use
%   CONV=[] for the default convention.  Note that fixed-precision integer
%   types can overflow for long braids.
%
%   Reference: P. Dehornoy, "Efficient solutions to the braid isotopy
%   problem," Discrete Applied Mathematics 156 (2008), 3091-3112.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.EQ, LOOP.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

if nargin < 2, conv = 'right'; end

if isempty(conv), conv = 'right'; end

if nargin > 2
  notypespec = false;
  if ischar(typ)
    htyp = str2func(typ);
  elseif isa(typ,'function_handle')
    htyp = typ;
  else
    error('BRAIDLAB:braid:loopcoords:badarg', ...
          'Third argument should be a type string or function handle.');
  end
else
  htyp = @int64;
  notypespec = true;
end

if strcmp(char(htyp),'vpi'), braidlab.util.checkvpi; end

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

try
  l = braidlab.loop(loopsigma(w,htyp(l.coords)));
catch err
  if notypespec  % Only try VPI if type wasn't explicitly specified.
    if strcmp(err.identifier,'BRAIDLAB:braid:sumg:overflow')
      warning('BRAIDLAB:braid:loopcoords:overflow',...
              'loopcoords overflowed... using VPI.')
      braidlab.util.checkvpi
      l = braidlab.loop(loopsigma(w,vpi(l.coords)));
    end
  else
    rethrow(err)
  end
end
