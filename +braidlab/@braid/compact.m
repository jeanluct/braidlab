function c = compact(b,annular)
%COMPACT   Try to shorten a braid by cancelling generators.
%   C = COMPACT(B) attempts to shorten a braid B by using group properties,
%   and returns the shortened braid C.  The group relations are
%
%     S(i) S(j) = S(j) S(i) ,   |i-j| > 1,   i,j = 1,..,n-1
%
%     S(i) S(i+1) S(i) = S(i+1) S(i) S(i+1),   i = 1,..,n-2
%
%   where S(i), i = 1,..n-1 are the Artin generators.
%
%   Note that COMPACT doesn't guarantee the shortest length, since this is a
%   co-NP-complete problem (Ref. [1]).  But it uses the algorithm in
%   Ref. [2] which is known to do pretty well at shortening braids.
%
%   References
%
%   [1] M. S. Paterson and A. A. Razborov, "The set of minimal braids is
%   co-NP-complete," J. Algorithms 12 (1991), 393-408.
%
%   [2] P. D. Bangert, M. A. Berger and R. Prandi, "In search of minimal
%   random braid configurations," J. Phys. A 35 (2002), 43-59.
%
%   This is a method for the BRAID class.
%   See also BRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <marko@clarkson.edu>
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

% Removed this check: it can easily overflow for long braids, but we should
% still be able to compact those.  This does mean that we will miss some
% trivial braids, but the user should really call istrivial separately if
% they suspect a trivial braid.  As a side effect, this can speed up
% compact a fair bit.
%if istrivial(b),
%  c = braidlab.braid([], b.n);
%  return;
%end

if ~isempty(b.word) && length(b) > 1
  % annular = true means an annular braid.
  if nargin < 2, annular = false; end
  bc = compact_helper(b.word,b.n,annular);
else
  bc = b.word;
end

c = braidlab.braid(bc,b.n);
