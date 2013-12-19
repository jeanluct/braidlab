function [varargout] = color_braiding(XY,t,proj)
%COLOR_BRAIDING   Find braid generators from trajectories using colored braids.
%   [GEN TCR CROSS_CELL] = COLOR_BRAIDING(XY,T) takes the inputs XY (the
%   trajectory set) and T (time) and calculates the corresponding generator
%   sequence via a color braiding method.  The color braiding method takes
%   pairs of strings and finds the crossings that occur between the two.
%   This is done for all pairs then the crossings for each pair are
%   converted to generators.  The outputs are the generator sequence (GEN),
%   the time of crossing (TCR), and the cell array containing times of
%   crossings for each pair of strings (CROSS_CELL).
%
%   See also COLOR_BRAIDING_SUB.

import braidlab.debugmsg

debugmsg('Part 1: Initialize parameters for crossing analysis')

n = size(XY,3); % number of punctures

if nargin < 3
  % Default projection line is X axis.
  proj = 0;
end

% Rotate coordinates according to angle proj.
% Note that since the projection line is supposed to be rotated by proj,
% we rotate the data by -proj.
if proj ~= 0
  XYr = zeros(size(XY));
  XYr(:,1,:) = cos(proj)*XY(:,1,:) + sin(proj)*XY(:,2,:);
  XYr(:,2,:) = -sin(proj)*XY(:,1,:) + cos(proj)*XY(:,2,:);
  XY = XYr; clear XYr;
end

% Check for coincident coordinate values.
% This is too slow... need to vectorize somehow.
needsnoise = false;
for i = 1:size(XY,1)
  XYi = squeeze(XY(i,:,:))';
  % Check if some particles occupy the exact same location, which
  % invalidates the braid computation.
  if size(unique(XYi,'rows'),1) ~= size(XYi,1)
    error('BRAIDLAB:braid:color_braiding:coincidentparticles',...
	  'Coincident particles: braid not defined.')
  end
  % Check if some particles have one coordinate in common.  The braid is
  % still well-defined, but warn the user.
  if (length(XYi(:,1)) ~= length(unique(XYi(:,1))) | ...
      length(XYi(:,2)) ~= length(unique(XYi(:,2))))
    needsnoise = true; break;
  end
end
if needsnoise
  % There are coincident values for the coordinates.  This can happen when
  % the data is discrete, such as when measured in pixels.  Just add a
  % tiny amount of noise to the data.  Later maybe best to change
  % projection line instead?
  warning('BRAIDLAB:braid:color_braiding:coincident',...
          'Coincident coordinates... adding a bit of noise.')
  noise = 1e-8;
  XY = XY.*(1 + noise*randn(size(XY)));
  % Maybe check if closed first, and re-close?
else
  needsnoise = false;
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

    % Determine the order of the x-coordinates, PERM.  Each crossing
    % corresponds to a change in sign of PERM.
    perm = sign(Xtraj1-Xtraj2);

    % Do some X coordinates coincide?
    if ~isempty(find(perm == 0))
      error('BRAIDLAB:braid:color_braiding:coincident',...
            'Somehow there are still coincident trajectories...')
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
