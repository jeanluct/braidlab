function [gen,tcr,cross_cell] = cross2gen(XYtraj,t,delta)
%CROSS2GEN   Convert a physical braid to a list of braid generators.
%   The order of each particle is determined according to its first (X)
%   coordinate.  Crossing happens when the X coordinate of two particles
%   match.  The second coordinate Y is used to determine whether the
%   particles exchanged their position in a clockwise or counter-clockwise
%   manner.
%
%   Output:
%
%   GEN - vector of integers corresponding to the sequence of
%   generators
%
%   TCR - vector of (interpolated) times at which generators
%   occurred
%
%   CROSS_CELL - Times at which a crossing occured is then stored into
%   CROSS_CELL in a numerical vector. The cell index (I,J) indicates both the
%   strings involved and the direction of crossing.  For example if strings I
%   and J cross with string I initially left of J, the time of the crossing
%   will be stored in CROSS_CELL(I,J); otherwise the time will be stored in
%   CROSS_CELL(J,I).  The direction of crossing -- either positive or negative
%   -- is saved in the same cell and is used to determine the generator
%   sequence later.  The outer I,J loop is over all pairs of strings.
%
%   This uses two helper functions, SORTCROSS and SORTCROSS2GEN.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2018  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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


import braidlab.util.debugmsg
tic;
n = size(XYtraj,3);

cross_cell = cell(n); % Cell array for crossing times.

%
% Cycle through all pairs of strings and find all crossings.
%

debugmsg('cross2gen: Search for crossings between pairs of strings',2);

for I = 1:n
  debugmsg([num2str(I) '/' num2str(n)],2) % Counter to monitor progress
  for J = I+1:n
    % Save the current pair of trajectories.
    Xtraj1 = XYtraj(:,1,I); Xtraj2 = XYtraj(:,1,J);
    Ytraj1 = XYtraj(:,2,I); Ytraj2 = XYtraj(:,2,J);

    % Check for coincident particles (terminally bad) or coincident
    % projection coordinates (usually fixed by a change in projection
    % angle).
    dXtraj = Xtraj1 - Xtraj2;

    % Use absolute precision to test equality.
    nearcoinc = find(abs(dXtraj) < delta);

    if ~isempty(nearcoinc)
      % Use absolute precision to test equality.
      if any(abs(Ytraj1(nearcoinc)-Ytraj2(nearcoinc)) < delta)
        error('BRAIDLAB:braid:colorbraiding:coincidentparticles', ...
              mat2str([I J]) )
      else
        error('BRAIDLAB:braid:colorbraiding:coincidentprojection', ...
              mat2str([I J]) )
      end
    end

    % Determine the order of the x-coordinates, PERM.  Each crossing
    % corresponds to a change in sign of PERM.
    perm = sign(dXtraj);

    % Do some X coordinates coincide?
    if ~isempty(find(perm == 0,1))
      error('BRAIDLAB:braid:colorbraiding:coincidentprojectionuncaught', ...
            'Somehow there are still coincident projection coordinates.')
    end

    ii = 1:length(perm)-1;
    icr = find(perm(ii+1) ~= perm(ii));
    if ~isempty(icr)
      % INTERPCROSS calculates the interpolated time of crossing.
      [tc,dY] = interpcross(t,[Xtraj1 Xtraj2],[Ytraj1 Ytraj2],icr,1,2);
      % Crossings where I was to the left of J
      icrIJ = find(perm(icr) < 0);
      cross_cell{I,J} = [tc(icrIJ) sign(dY(icrIJ))];
      % Crossings where J was to the left of I
      icrJI = find(perm(icr) > 0);
      cross_cell{J,I} = [tc(icrJI) -sign(dY(icrJI))];
    end
  end
end

% CROSS_CELL contains the crossing times and directions for string pairings
% which are initially in the order I,J along the projection line.  These
% have to be sorted and converted to generators.

[gen,tcr] = sortcross2gen(n,sortcross(cross_cell));
