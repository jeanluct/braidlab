function crossdat = sortcross(cross_cell)
%SORTCROSS   Sort crossing times.
%   CROSSDAT = SORTCROSS(CROSS_CELL)
%   CROSS_CELL contains the crossing times and directions for string pairings
%   which are initially in the order I,J along the projection line.  These
%   have to be sorted chronologically and validated.
%
%   CROSSDAT will be a matrix with crossing information:
%   Column 1: time;
%   Column 2: direction;
%   Column 3: leftmost string;
%   Column 4: rightmost string.
%
%   This is a helper function for CROSS2GEN.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <marko@clarkson.edu>
%                       Michael Allshouse <m.allshouse@northeastern.edu>
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

import braidlab.util.debugmsg

n = size(cross_cell,1);

debugmsg('sortcross: Sorting the pair crossings into the generator sequence');

% Precompute the total size of crossdat.  For large number of particles
% (>60), the recurring memory allocation needed to 'grow' crossdat becomes
% prohibitive.  For instance, for 100 particles get a speedup of
% almost four for the function as a whole.
cellsize = cellfun('size',cross_cell,1);  % size of each cell element
totalsize = sum(sum(cellsize));           % total size of crossdat
crossdat = zeros(totalsize,4);            % allocate crossdat
k = 1;
for I = 1:n
  for J = 1:n
    if cellsize(I,J) > 0
      k1 = k + cellsize(I,J) - 1;
      crossdat(k:k1,1:2) = cross_cell{I,J};
      crossdat(k:k1,3) = ones(cellsize(I,J),1)*I;
      crossdat(k:k1,4) = ones(cellsize(I,J),1)*J;
      k = k1 + 1;
    end
  end
end

% Sort the data based on time of crossing.
crossdat = sortrows(crossdat);

debugmsg(sprintf(['sortcross: Computing sorted crossdat took' ...
                  ' %f msec.'], toc*1000));

debugmsg(sprintf('sortcross: Number of crossings: %d\n', size(crossdat,1)),2);
