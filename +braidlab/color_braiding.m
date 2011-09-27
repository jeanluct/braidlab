function [varargout] = color_braiding(XY,t)
%COLOR_BRAIDING   Find braid generators from trajectories using colored braids.
%   [GEN TCR CROSS_CELL] = COLOR_BRAIDING(XY,T) takes the inputs XY (the
%   trajectory set) and T (time) and calculates the corresponding generator
%   sequence via a color braiding method.  The color braiding method takes
%   pairs of strands and finds the crossings that occur between the two.
%   This is done for all pairs then the crossings for each pair are
%   converted to generators.  The outputs are the generator sequence (GEN),
%   the time of crossing (TCR), and the cell array containing times of
%   crossings for each pair of strands (CROSS_CELL).
%
%   See also COLOR_BRAIDING_SUB.

import braidlab.interpcross braidlab.debugmsg

debugmsg('Part 1: Initialize parameters for crossing analysis')

n = size(XY,3); % number of punctures

% Sort the trajectories from left to right according to their initial x coord.
XYini = zeros(n,2); % Initial condition matrix
for i = 1:n
  XYini(i,:) = [XY(1,1,i) XY(1,2,i)];
end
[XYs Ind] = sortrows(XYini); % Sort the initial conditions;
                             % IND contains the indices of the sort.

% Create the sorted trajectories and store as XYtraj.
XYtraj = zeros(size(XY));
for i = 1:n
  XYtraj(:,1,i) = XY(:,1,Ind(i));
  XYtraj(:,2,i) = XY(:,2,Ind(i));
end

cross_cell = cell(n); % cell array for crossing times.

debugmsg('Part 2: Search for crossings between pairs of strands')

%
% Cycle through all pairs of strands and find all crossings.
%
%  The time at which a crossing occured is then storred into CROSS_CELL.
%  Its location indicates both the strands involved and the direction of
%  crossing.  For example if strands I and J cross with strand I initially
%  left of J, the time of the crossing will be stored in CROSS_CELL(I,J);
%  otherwise the time will be stored in CROSS_CELL(J,I).  The direction of
%  crossing -- either positive or negative -- is saved in the same cell and
%  is used to determine the generator sequence later.  The outer I,J loop is
%  over all pairs of strands.
%

for I = 1:n
  debugmsg([num2str(I) '/' num2str(n)]) % Counter to monitor progress

  for J = I+1:n

    % Save the current pair of trajectories.
    x_traj1 = XYtraj(:,1,I); y_traj1 = XYtraj(:,2,I);
    x_traj2 = XYtraj(:,1,J); y_traj2 = XYtraj(:,2,J);

    % Determine the order of the x-coordinates, PERM.  Each crossing
    % corresponds to a change in sign of PERM.
    perm = sign(x_traj1-x_traj2);
    % If the permutation really is zero, look to the previous time to
    % determine if there was a sign change.
    izero = find(perm == 0);
    if ~isempty(izero)
      if izero(1) == 1
	% Solve this by perturbing instead.
	error('BRAIDLAB:color_braiding:badstart', ...
	      'Particles %d and %d initially have the same X coordinate.', ...
	      I,J);
      end
      for i = 1:length(izero)
	perm(izero(i)) = perm(izero(i)-1);
      end
    end

    %
    % At each time step, determine if there was a crossing.
    %
    %  Crossings occur when there has been a change in the value of PERM
    %  from one time step to the next.
    %
    %  Two special cases have to be taken into account.
    %
    %  1) If the two points happen to have the same x-coordinate then either
    %  a crossing is occuring at that moment or the points are colliding
    %  (i.e. have the same y-coordinate).
    %
    %  2) If the trajectories have the same x-coordinate the value of PERM
    %  at this instant will be 0.
    %

    ii = 1:length(perm)-1;
    icr = find(perm(ii+1) ~= perm(ii));
    if ~isempty(icr)
      % INTERPCROSS calculates the interpolated time of crossing.
      [tc,dY] = interpcross(t,[x_traj1 x_traj2],[y_traj1 y_traj2],icr,1,2);
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
% strand pairings which are initially in the order I,J along the projection
% line.  These have to be sorted and verified.

% crossdat will be a matrix with crossing information:
% Column 1: time. Column 2: direction. Column 3: lower strand. Column 4:
% higher strand.

% Cycle through all cells.
if true
  % Precompute the total size of crossdat.  For large number of particles
  % (>60), the recurring memory allocation needed to 'grow' crossdat becomes
  % prohibitive.  For instance, for 100 particles I get a speedup of
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
else % This is the old method.
  crossdat = [];
  for I = 1:n
    for J = 1:n
      if ~isempty(cross_cell{I,J})
	crossdat = [crossdat; cross_cell{I,J} ...
		    ones(size(cross_cell{I,J},1),1)*I ...
		    ones(size(cross_cell{I,J},1),1)*J];
      end
    end
  end
end

% Sort the data based on time of crossing.
crossdat = sortrows(crossdat);

% To determine the magnitude of the generator, the crossings have to be
% applied to the system and the location of the lower strand in the crossing
% will be the magnitude of the generator.  The direction of crossing
% calculated earlier is then applied to get the generator value.

Iperm = 1:n; % initial permutation vector

% Create the generator and time of crossing, tcr, vectors.
gen = zeros(size(crossdat,1),1);
tcr = zeros(size(crossdat,1),1);

% Cycle through each crossing, apply, and calculate the corresponding
% generator.
for i = 1:size(crossdat,1)
  ind_1 = find(Iperm == crossdat(i,3)); % Find the location of the lower strand
  if Iperm(ind_1+1) == crossdat(i,4)    % If the higher strand is in fact the
				        % next strand to the right apply the
                                        % crossing.
    Iperm(ind_1:ind_1+1) = [crossdat(i,4) crossdat(i,3)]; % update index vector
    gen(i) = ind_1*crossdat(i,2); % save the generator
    tcr(i) = crossdat(i,1);       % save the time of crossing
  else
    % If for some reason the two strands crossing are not next to each
    % other an error has occured and the program will stop and give some
    % information on the break point.
    fs = ['crossdat inconsistency at crossing %d, time %f' ...
	  ' with permutation [' num2str(Iperm) '].'];
    msg = sprintf(fs,i,crossdat(i,1));
    error('BRAIDLAB:color_braiding:badcrossing',msg)
  end
end

varargout{1} = braidlab.braid(gen,n);
if nargout > 1, varargout{2} = tcr; end
if nargout > 2, varargout{3} = cross_cell; end
