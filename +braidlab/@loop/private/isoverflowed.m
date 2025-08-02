function out = isoverflowed(v)
% If argument is an integer, test it against the overflow boundaries for its
% class.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2025  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

% for integers, we have an upper and a lower boundary - test against each
if isinteger(v)
  myMax = intmax(class(v));
  myMin = intmin(class(v));
  out = any( v >= myMax) || any(v <= myMin );

elseif isfloat(v)
  % for doubles there is just a max, so test the absolute value against it
  myMax = realmax(class(v));
  out = any( abs(v) >= myMax );
else
  out = false;
end
