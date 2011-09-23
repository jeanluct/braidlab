function [varargout] = color_braiding(X,t)
%COLOR_BRAIDING   Find braid generators from trajectories using colored braids.
%   [GEN TCR CROSS_CELL] = COLOR_BRAIDING(X,T) is a code which take the
%   inputs X (the trajectory set) and T (time) and calculates the
%   corresponding generator sequence via a color braiding method.  The color
%   braiding method takes pairs of strands and finds the crossings that
%   occur between the two.  This is done for all pairs then the crossings
%   for each pair are converted to generators.  The outputs for this code
%   are the generator sequence (GEN), the time of crossing (TCR), and the
%   cell structure containing times of crossings for each pair of strands
%   (CROSS_CELL).
%
%   See also COLOR_BRAIDING_SUB.

% JLT->MRA: Is there a reason you changed the arguments from gencross?
% gencross takes (t,X,Y).

import braidlab.interpcross braidlab.debugmsg

debugmsg('Part 1: Initialize parameters for crossing analysis')

n = size(X,3); % number of punctures

% Sort the trajectories from left to right according to their initial x coord.
Xini = zeros(n,2); % Initial condition matrix
for i = 1:n
  Xini(i,:) = [X(1,1,i) X(1,2,i)];
end
[Xs Ind] = sortrows(Xini); % Sort the initial conditions;
                           % IND contains the indices of the sort.

% Create the sorted trajectories and store as Xtraj.
Xtraj = 0*X;
for i = 1:n
  Xtraj(:,1,i) = X(:,1,Ind(i));
  Xtraj(:,2,i) = X(:,2,Ind(i));
end

cross_cell = cell(n); % cell structure for crossing times.

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

% JLT->MRA: check previous paragraph after my edits.

for I = 1:n
  debugmsg([num2str(I) '/' num2str(n)]) % Counter to monitor progress

  for J = I+1:n

    % Save the current pair of trajectories.
    x_traj1 = Xtraj(:,1,I); y_traj1 = Xtraj(:,2,I);
    x_traj2 = Xtraj(:,1,J); y_traj2 = Xtraj(:,2,J);

    % Determine the order of the x-coordinates, PERM.  Each crossing
    % corresponds to a change in sign of PERM.
    perm = sign(x_traj1-x_traj2);
    % If the permutation really is zero, look to the previous time to
    % determine if there was a sign change.
    izero = find(perm == 0);
    if ~isempty(izero)
      if izero(1) == 1
	% JLT->MRA: small fix: if izero(1)=1 (particles start at the same
	% spot) then the previous code crashed, since perm(0) was accessed.
	% Instead, give an error in that case.
	% Maybe this should just be a warning?
	error('BRAIDLAB:color_braiding:badstart', ...
	      'Particles %d and %d initially have the same X coordinate.', ...
	      I,J);
      end
      % JLT->MRA: Couldn't there be very rare instances where there are two
      % or more consecutive zeros in perm?  In other words the position of
      % the two particles coincides for several consecutive timesteps.  The
      % solution I think is to explicitly loop to make
      % perm(izero)=perm(izero-1), since then the zeros would be overwritten?
      for i = 1:length(izero)
	perm(izero(i)) = perm(izero(i)-1);
      end
      %perm(izero) = perm(izero-1); % loop above replaces this line
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

    % JLT->MRA: check previous paragraph after my edits.

    % JLT->MRA: vectorized this inner part (required vectorizing
    % interpcross).  Speedup of a factor of 30 for 8 particles!

    ii = 1:length(perm)-1;
    icr = find(perm(ii+1) ~= perm(ii));
    if ~isempty(icr)
      % INTERPCROSS calculates the interpolated time of crossing.
      [tc,dY] = interpcross(t,[x_traj1 x_traj2],[y_traj1 y_traj2],icr,1,2);
      if any(dY == 0)
	error('BRAIDLAB:color_braiding:intersect','Intersecting points.');
	% JLT->MRA: isn't this caught in interpcross?
      end
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
% strand pairings which are initially in the order I,J.  These have to be
% sorted and verified.

% JLT->MRA: "in the order I,J": what does that mean?

% crossdat will be a matrix with crossing information:
% Column 1: time. Column 2: direction. Column 3: lower strand. Column 4:
% higher strand.
crossdat = [];

% JLT->MRA: renamed t_cross to crossdat.

% JLT->MRA: lower/higher same as to the left/to the right?

% Cycle through all cells.
for I = 1:n
  for J = 1:n
    if ~isempty(cross_cell{I,J})
      crossdat = [crossdat; cross_cell{I,J} ...
		  ones(size(cross_cell{I,J},1),1)*I ...
		  ones(size(cross_cell{I,J},1),1)*J];
    end
  end
end

% JLT->MRA: I don't quite understand the previous loop.

% Sort the data based on time of crossing.
crossdat = sortrows(crossdat);

% To determine the magnitude of the generator, the crossings have to be
% applied to the system and the location of the lower strand in the crossing
% will be the magnitude of the generator.  The direction of crossing
% calculated earlier is then applied to get the generator value.

Iperm = 1:n; % initial permutation vector

% Create the generator and time of crossing, tcr, vectors.
gen = zeros(size(crossdat,1),1);
tcr = gen; % JLT->MRA: do you mean you're also setting this to zero?

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

varargout{1} = gen;
if nargout > 1, varargout{2} = tcr; end
if nargout > 2, varargout{3} = cross_cell; end
