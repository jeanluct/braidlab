function c = tensor(varargin)
%TENSOR   Tensor product of databraids.
%   C = TENSOR(B1,B2) returns the tensor product of the databraids B1 and
%   B2, which is the databraid obtained by laying B1 and B2 side-by-side,
%   with B1 on the left.  The crossing times are sorted chronologically.
%
%   C = TENSOR(B1,B2,B3,...) returns the tensor product of several
%   databraids.
%
%   This is a method for the DATABRAID class.
%   See also DATABRAID, BRAID.TENSOR.

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

if nargin < 2
  error('BRAIDLAB:databraid:tensor:badarg', ...
        'Need at least two databraids.')
elseif nargin == 2
  a = varargin{1}; b = varargin{2};
  % Sort, but keep track of index changes.
  [tcr,idx] = sort([a.tcross b.tcross]);
  ab = tensor@braidlab.braid(a,b);
  % Re-order the generators according to sorting.
  ab.word = ab.word(idx);
  c = braidlab.databraid(ab,tcr);
else
  c = tensor(varargin{1},tensor(varargin{2:end}));
end
