function [gen,tcr] = sortcross2gen(n,crossdat)
%SORTCROSS2GEN   Convert sorted crossing data to generators.
%   [GEN,TCR] = SORTCROSS2GEN(CROSSDAT)
%   CROSSDAT is the output of SORTCROSS.
%
%   To determine the generator, the crossings have to be applied to the
%   particle order.  The location of the lower string in the crossing will
%   be the magnitude of the generator.  The direction of crossing calculated
%   earlier is then applied to get the generator value.
%
%   This is a helper function for CROSS2GEN.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
%                        Michael Allshouse <mallshouse@chaos.utexas.edu>
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
        error('BRAIDLAB:braid:sortcross2gen:badcrossing', ...
              fs,i,crossdat(i,1),idx1)
      end
      % Swap the good crossing with the current one.
      debugmsg(sprintf('sortcross2gen: Swap crossings %d and %d',i,j))
      temp = crossdat(i,:);
      crossdat(i,:) = crossdat(j,:);
      crossdat(j,:) = temp;
      % Since notcrossed is still false, the while loop will force a
      % recheck and detect the j crossing.
    end
  end
end
