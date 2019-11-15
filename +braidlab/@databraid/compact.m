function c = compact(b)
%COMPACT   Try to shorten a databraid by cancelling generators.
%   C = COMPACT(B) attempts to shorten a databraid B by cancelling
%   adjacent generators, and returns the shortened databraid C.  The
%   crossing times corresponding to the cancelled generators are
%   dropped from the TCROSS data member of C.
%
%   Note that DATABRAID.COMPACT is less effective than BRAID.COMPACT,
%   since it preserves the order of generators.  It does this in order
%   to maintain the ordering of the crossing times.
%
%   This is a method for the DATABRAID class.
%   See also BRAID.COMPACT.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2019  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

c = b;

% Keep cancelling until nothing changes.
shorter = true;
while shorter
  [c,shorter] = canceladj(c);
end

%====================================================================
function [cc,shorter] = canceladj(cc)

shorter = false;

w = cc.word;  % Make a copy, to avoid braid.set method.

i1 = 1:2:length(w)-1;
ic = find(w(i1) == -w(i1+1));
if ~isempty(ic), shorter = true; end
w(i1(ic)) = 0; w(i1(ic)+1) = 0;

i2 = 2:2:length(w)-1;
ic = find(w(i2) == -w(i2+1));
if ~isempty(ic), shorter = true; end
w(i2(ic)) = 0; w(i2(ic)+1) = 0;

i0 = find(w ~= 0);
cc.tcross = cc.tcross(i0);
cc.word = w(i0);
