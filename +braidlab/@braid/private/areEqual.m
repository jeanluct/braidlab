function result = areEqual(A,B,D) %#ok<STOUT,INUSD>
%AREEQUAL   Check for equality within a given precision.
%   AREEQUAL(A,B,D) Checks if elements of A and B are within
%   D (int exponent) float-representable numbers.
%
%   Returns a logical matrix of size equal to A and B containing results of
%   tests.
%
%   AREEQUAL is implemented as a MATLAB MEX file. This file holds only its
%   documentation.
%
%   Example
%      A = rand(10,10);
%      areEqual(A,A+5*eps(A),5)
%      areEqual(A,A+5*eps(A),3)

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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


assert( all(A(:) < B(:)), 'BRAIDLAB:areEqual:badarg', ['Input arguments ' ...
                    'have to be in A < B order'] );

result = reshape( B(:) <= nextafter(A(:), D), size(A) );

end

function y = nextafter(x,d)
%NEXTAFTER Increment last bit of a floating point number.
% NEXTAFTER(X) adds one unit to the last place of X.
% NEXTAFTER(X,D) for positive D does the same thing.
% NEXTAFTER(X,D) for negative D subtracts one unit ("Next Before")
% Examples:
% nextafter(1) is 1 + eps
% nextafter(1,-1) is 1 - eps/2
% nextafter(0) is the smallest floating point number.
%
% Adapted from a function by Cleve Moler:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/192
   
[f,e] = log2(abs(x));
u = pow2(2,e-54);
if x == 0, 
  u = eps*realmin; 
end

if nargin < 2, 
  d = 1; 
end

if d == 0
  y = x;
  return;
end

if d < 0, 
  u = -u; 
end

if f == 1/2 & sign(x) ~= sign(d), 
  u = u/2; 
end

y = nextafter(x, d - sign(d)) + u; 

end