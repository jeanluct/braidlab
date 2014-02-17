function [varargout] = color_braiding(XY,t,proj)
%COLOR_BRAIDING   Find braid generators from trajectories using colored braids.
%   B = COLOR_BRAIDING(XY,T) takes the inputs XY (the trajectory set) and T
%   (vector of times) and calculates the corresponding braid B via a color
%   braiding method.
%
%   The color braiding method takes pairs of strings and finds the crossings
%   that occur between the two.  This is done for all pairs, and then the
%   crossings for each pair are converted to generators.
%
%   [B,TCR] = COLOR_BRAIDING(XY,T) also returns the time of crossing (TCR).
%
%   [B,TCR,CROSS_CELL] = COLOR_BRAIDING(XY,T) also returns the cell array
%   containing times of crossings for each pair of strings (CROSS_CELL).
%
%   The projection line angle PROJANG can be specified as an optional
%   third argument (default 0).
%
%   COLOR_BRAIDING is a protected static method of the BRAID class.  It
%   is also used by the DATABRAID subclass.
%
%   See also BRAID, BRAID.BRAID, DATABRAID, DATABRAID.DATABRAID.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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

import braidlab.debugmsg

debugmsg('Part 1: Initialize parameters for crossing analysis')

n = size(XY,3); % number of punctures

if nargin < 3
  % Default projection line is X axis.
  proj = 0;
end

% Rotate coordinates according to angle proj.  Note that since the
% projection line is supposed to be rotated counterclockwise by proj, we
% rotate the data clockwise by proj.
if proj ~= 0
  XY = rotate_data_clockwise(XY,proj);
end

% Sort the initial conditions from left to right according to their initial
% X coord; IDX contains the indices of the sort.
[~,idx] = sortrows(squeeze(XY(1,:,:)).');
% Sort all the trajectories trajectories according to IDX:
XYtraj = XY(:,:,idx);

cross_cell = cell(n); % Cell array for crossing times.

debugmsg('Part 2: Search for crossings between pairs of strings')

%
% Cycle through all pairs of strings and find all crossings.
%
%  The time at which a crossing occured is then storred into CROSS_CELL.
%  Its location indicates both the strings involved and the direction of
%  crossing.  For example if strings I and J cross with string I initially
%  left of J, the time of the crossing will be stored in CROSS_CELL(I,J);
%  otherwise the time will be stored in CROSS_CELL(J,I).  The direction of
%  crossing -- either positive or negative -- is saved in the same cell and
%  is used to determine the generator sequence later.  The outer I,J loop is
%  over all pairs of strings.
%

for I = 1:n
  debugmsg([num2str(I) '/' num2str(n)]) % Counter to monitor progress
  for J = I+1:n
    % Save the current pair of trajectories.
    Xtraj1 = XYtraj(:,1,I); Xtraj2 = XYtraj(:,1,J);
    Ytraj1 = XYtraj(:,2,I); Ytraj2 = XYtraj(:,2,J);

    % Check for coincident particles (terminally bad) or coincident
    % projection coordinates (usually fixed by a change in projection
    % angle).
    dXtraj = Xtraj1 - Xtraj2;
    nearcoinc = find(abs(dXtraj) < 10*eps);
    if ~isempty(nearcoinc)
      dYtraj = Ytraj1(nearcoinc) - Ytraj2(nearcoinc);
      if any(abs(dYtraj) < 10*eps)
        error('BRAIDLAB:braid:color_braiding:coincidentparticles',...
              'Coincident particles: braid not defined.')
      else
        error('BRAIDLAB:braid:color_braiding:coincidentproj',...
              [ 'Coincident projection coordinate; change ' ...
                'projection angle (type help braid.braid).' ])
      end
    end

    % Determine the order of the x-coordinates, PERM.  Each crossing
    % corresponds to a change in sign of PERM.
    perm = sign(dXtraj);

    % Do some X coordinates coincide?
    if ~isempty(find(perm == 0))
      error('BRAIDLAB:braid:color_braiding:coincidentproj',...
            'Somehow there are still coincident projection coordinates...')
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

debugmsg('Part 3: Sorting the pair crossings into the generator sequence')

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
        msg = sprintf(fs,i,crossdat(i,1),idx1);
        error('BRAIDLAB:color_braiding:badcrossing',msg)
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

varargout{1} = braidlab.braid(gen,n);
if nargout > 1, varargout{2} = tcr; end
if nargout > 2, varargout{3} = cross_cell; end

% =========================================================================
function XYr = rotate_data_clockwise(XY,proj)

XYr = zeros(size(XY));
XYr(:,1,:) = cos(proj)*XY(:,1,:) + sin(proj)*XY(:,2,:);
XYr(:,2,:) = -sin(proj)*XY(:,1,:) + cos(proj)*XY(:,2,:);
