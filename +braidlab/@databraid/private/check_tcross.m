function br = check_tcross(br)
%CHECK_TCROSS   Validate crossing times.

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

% Must have as many times as the word length.
if length(br.word) ~= length(br.tcross)
  error('BRAIDLAB:databraid:check_tcross:badtimes', ...
        'Must have as many crossing times as generators.')
end

% Cannot have decreasing times.
dt = diff(br.tcross);
if any(dt < 0)
  error('BRAIDLAB:databraid:check_tcross:badtimes', ...
        'Crossing times must be nondecreasing.')
end

% Check: if there are simultaneous crossings, they must correspond to
% commuting generators.
sort_sim_tcross(br);
