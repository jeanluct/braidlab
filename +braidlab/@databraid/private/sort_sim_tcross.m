function br = sort_sim_tcross(br)
%SORT_SIM_TCROSS   Sort generators that have simultaneous crossing times.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

dt = diff(br.tcross);
dt = dt(:).';

runs = diff(find([1,dt,1]));  % Find run lengths of simultaneous crossing times
starts = find([1,dt]);        % Find where they start

% Keep only runs of length > 1.
starts = starts(runs > 1);
runs = runs(runs > 1);

% Now loop over each run block.
for i = 1:length(runs)
  % The word of generators for this run.
  w = br.word(starts(i):starts(i)+runs(i)-1);
  % Sort according to absolute index of generators.
  [~,idx] = sort(abs(w)); w = w(idx);
  % The differences between absolute values must all be > 1, indicating the
  % generators commute.  Otherwise it's an error.
  if any(diff(abs(w)) <= 1)
    error('BRAIDLAB:databraid:sort_sim_tcross:badsimtimes', ...
          ['Cannot have simultaneous crossing times ' ...
           'for noncommuting generators.'])
  end
  br.word(starts(i):starts(i)+runs(i)-1) = w;
end
