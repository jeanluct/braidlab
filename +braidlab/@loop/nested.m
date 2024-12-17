function lvl = nested(obj)
%NESTED   Nesting level of loop.
%   LVL = NESTED(L) returns the nesting level of a loop.  This is the
%   GCD of all the loop coordinate entries, minus one.  If the loop is
%   not nested, then LVL=0.  If the loop is doubled, LVL=1, etc.
%
%   This is a method for the LOOP class.
%   See also LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

lvl = zeros(size(obj.coords,1),1);
for j = 1:size(obj.coords,1)
  lvl(j) = gcd(obj.coords(j,1),obj.coords(j,2));
  for i = 3:length(obj.coords(j,:))
    lvl(j) = gcd(lvl(j),obj.coords(j,i));
  end
  lvl(j) = lvl(j)-1;
end
