function [gen,tcr,cross_cell] = cross2gen(XYtraj,t)
%CROSS2GEN   Convert a physical braid to a list of braid generators.
%
%   The order of each particle is determined according to its first (X)
%   coordinate.
%   Crossing happens when the X coordinate of two particles match.
%   The second coordinate Y is used to determine whether the particles
%   exchanged their position in a clockwise or counter-clockwise manner.
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
%   <LICENSE
%     Braidlab: a Matlab package for analyzing data using braids
%
%     http://github.com/jeanluct/braidlab
%
%     Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                              Marko Budisic         <marko@math.wisc.edu>
%                          Michael Allshouse <mallshouse@chaos.utexas.edu>
%
%     This file is part of Braidlab.
%
%     Braidlab is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     Braidlab is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
%   LICENSE>


import braidlab.util.debugmsg
tic;
n = size(XYtraj,3);

cross_cell = cell(n); % Cell array for crossing times.

%
% Cycle through all pairs of strings and find all crossings.
%

debugmsg(['colorbraiding Part 2: Search for crossings between pairs of' ...
          ' strings']);

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

    % Use relative precision to test equality (same as C++ code).
    nearcoinc = find(areEqual(Xtraj1, Xtraj2, 10));

    if ~isempty(nearcoinc)
      % Use relative precision to test equality (same as C++ code).
      if any(areEqual(Ytraj1(nearcoinc),Ytraj2(nearcoinc),10))
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

debugmsg(['colorbraiding Part 3: ' ...
          'Sorting the pair crossings into the generator sequence']);

% At this point CROSS_CELL contains the crossing times and directions for
% string pairings which are initially in the order I,J along the projection
% line.  These have to be sorted and verified.

% crossdat will be a matrix with crossing information:
% Column 1: time; Column 2: direction; Column 3: leftmost string; Column 4:
% rightmost string.

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

debugmsg(sprintf(['colorbraiding: computing sorted crossdat took' ...
                  ' %f msec.'], toc*1000));

debugmsg(sprintf('colorbraiding:Number of crossings: %d\n', ...
                 size(crossdat,1)),2);

% To determine the generator, the crossings have to be applied to the
% particle order.  The location of the lower string in the crossing will be
% the magnitude of the generator.  The direction of crossing calculated
% earlier is then applied to get the generator value.

Iperm = 1:n; % initial permutation vector

% Create the generator and time of crossing, tcr, vectors.
gen = zeros(size(crossdat,1),1);
tcr = zeros(size(crossdat,1),1);

% Cycle through each crossing, apply, and calculate the corresponding
% generator.
for i = 1:size(crossdat,1)
  notcrossed = true;
  while notcrossed
    % Find the location of the lower string.
    idx1 = find(Iperm == crossdat(i,3));
    if Iperm(idx1+1) == crossdat(i,4)  % If the higher string is in fact the
                                       % next string to the right, then
                                       % apply the crossing.
      Iperm(idx1:idx1+1) = [crossdat(i,4) crossdat(i,3)]; % update index vector
      gen(i) = idx1*crossdat(i,2); % save the generator
      tcr(i) = crossdat(i,1);      % save the time of crossing
      notcrossed = false;          % everything is ok: we crossed, so move on
    else
      % The higher string is not the next string.  This possibly indicates a
      % simultaneous crossing of three or more strings.  Let's look for a
      % plausible crossing occuring at the same time.
      icm = find(crossdat(:,1) == crossdat(i,1)); % crossings at same time
      goodcross = [];
      for j = icm'  % Loop over these crossings, looking for one that
                    % involves adjacent particles.
        idx1 = find(Iperm == crossdat(j,3));
        idx2 = find(Iperm == crossdat(j,4));
        if idx1+1 == idx2, goodcross = j; break; end  % adjacent: we're done
      end
      if isempty(goodcross)
        % Cannot find two strings crossing that are not next to each other.
        fs = ['crossdat inconsistency at crossing %d, time %f, index %d,' ...
              ' with permutation [' num2str(Iperm) '].'];
        error('BRAIDLAB:braid:colorbraiding:badcrossing', ...
              fs,i,crossdat(i,1),idx1)
      end
      % Swap the good crossing with the current one.
      debugmsg(sprintf('Swap crossings %d and %d',i,j))
      temp = crossdat(i,:);
      crossdat(i,:) = crossdat(j,:);
      crossdat(j,:) = temp;
      % Since notcrossed is still false, the while loop will force a
      % recheck and detect the j crossing.
    end
  end
end

