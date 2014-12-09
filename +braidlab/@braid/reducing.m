function l = reducing(b,ntries)
%REDUCING   Find reducing curves for a braid, if they exist.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP.LOOP, BRAID.CYCLE.

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

% Test with the bad reducible braid:
%   b = braid([-3  1 -4  2 -3 -1 -2  3 -2  4  3  4]);
% Reducing curve is
%   lred = loop([0 -1 0 0 0 0 0 1]);

warning('BRAIDLAB:braid:reducing:exp', ...
        'This function is experimental!  Use with caution!')

if nargin < 2, ntries = 5; end

lc = [];
for i = 1:ntries
  l = find_reducing_curves(b);
  for j = 1:length(l)
    lc = [lc ; l(j).coords];
  end
end

lc = unique(lc,'rows');

if ~isempty(lc)
  l = braidlab.loop(lc);
else
  l = [];
end
