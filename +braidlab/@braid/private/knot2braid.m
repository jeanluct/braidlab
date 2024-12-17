function b = knot2braid(K)
%KNOT2BRAID   Return a braid representative for a knot.
%   B = KNOT2BRAID(K) returns a braid representative B for the knot K.
%   The knot is denoted in standard coding as '0_1', '3_1', '5_2', etc.
%   Currently knots up to 8 crossings are represented.
%
%   Reference:
%
%   The knots correspond to the Rolf# column in Table 1 here:
%   https://arxiv.org/pdf/math/0401051
%
%   The braid representatives were originally obtained from
%     http://homepages.warwick.ac.uk/~maaac/images/knot_braid_rep.jpg
%   which is now a broken link, so may differ.
%
%   See also ALEXPOLY, BRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <mbudisic@gmail.com>
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
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

import braidlab.braid

switch lower(K)
 case {'0_1','unknot'}
  b = braid([1]); %#ok<NBRAK>
 case {'3_1','trefoil'}
  b = braid([1 1 1]);
 case {'4_1','figure-eight','figure-8'}
  b = braid([1 -2 1 -2]);
 case '5_1'
  b = braid([1 1 1 1 1]);
 case '5_2'
  b = braid([2 2 -1 2 1 1]);
 case '6_1'
  b = braid([1 -2 1 -3 2 -3 -2]);
 case '6_2'
  b = braid([-1 2 -1 2 2 2]);
 case '6_3'
  b = braid([-1 2 2 -1 -1 2]);
 case '7_1'
  b = braid([1 1 1 1 1 1 1]);
 case '7_2'
  b = braid([-1 3 3 3 2 1 1 -3 2]);
 case '7_3'
  b = braid([2 2 2 2 2 1 2 2 -1 -1]);
 case '7_4'
  b = braid([3 3 -1 2 -3 2 1 1 2]);
 case '7_5'
  b = braid([2 2 2 1 2 2 2 2 -1 -1]);
 case '7_6'
  b = braid([-3 -1 2 1 1 -3 -2 -2 -2]);
 case '7_7'
  b = braid([1 -3 2 -3 2 -1 2 -3 2]);
 case '8_1'
  b = braid([1 -2 -3 2 1 -4 -4 -3 -2 4]);
 case '8_2'
  b = braid([2 2 2 2 2 -1 2 -1]);
 case '8_3'
  b = braid([1 2 -3 -4 -3 2 -1 3 3 2 4 -3 -2 -2]);
 case '8_4'
  b = braid([1 1 1 3 -2 -3 -3 1 -2]);
 case '8_5'
  b = braid([1 1 1 -2 1 1 1 -2]);
 case '8_6'
  b = braid([-3 -3 1 -2 1 3 -2 -2 -2]);
 case '8_7'
  b = braid([-2 -2 1 -2 1 1 1 1]);
 case '8_8'
  b = braid([-1 2 1 1 -3 2 2 -3 -3]);
 case '8_9'
  b = braid([2 2 2 -1 2 -1 -1 -1]);
 case '8_10'
  b = braid([2 2 -1 -1 2 2 2 -1]);
 case '8_11'
  b = braid([1 -2 -2 3 -2 -3 -3 1 -2]);
 case '8_12'
  b = braid([1 -2 3 -4 3 -4 2 1 -3 -2]);
 case '8_13'
  b = braid([1 1 2 -3 2 -1 -3 -3 2]);
 case '8_14'
  b = braid([1 1 2 2 -1 -3 2 -3 2]);
 case '8_15'
  b = braid([1 1 1 2 3 -1 2 2 2 3 -2]);
 case '8_16'
  b = braid([1 1 -2 1 1 -2 1 -2]);
 case '8_17'
  b = braid([2 -1 2 -1 2 2 -1 -1]);
 case '8_18'
  b = braid([1 -2 1 -2 1 -2 1 -2]);  % Error in table.
 case '8_19'
  b = braid([1 2 1 2 1 2 2 1]);
 case '8_20'
  b = braid([2 1 1 1 2 -1 -1 -1]);
 case '8_21'
  b = braid([2 2 2 1 2 2 -1 -1 2 -1]);
 otherwise
  error('BRAIDLAB:braid:knot2braid:unknown','Unknown knot %s',K)
end
