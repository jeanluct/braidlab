function bt = trunc(b,interval)
%TRUNC   Truncate a databraid by choosing crossings from a time subinterval.
%   BT = TRUNC(B,INTERVAL) truncates the braid generators to those
%   whose crossing times TCROSS lie in the interval
%
%      INTERVAL(1) <= TCROSS <= INTERVAL(2).
%
%   If INTERVAL is a single number, then selected crossings will have
%   TCROSS <= INTERVAL.
%
%   This is a method for the DATABRAID class.

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

bt = b;
if nargin < 2 || ~isnumeric(interval)
  error('BRAIDLAB:databraid:trunc:badarg','Not enough input arguments.')
end

if isempty(interval) || numel(interval) < 1 || numel(interval) > 2
  error('BRAIDLAB:databraid:trunc:badarg',...
        'Interval has to be a non-empty 1 or 2 element vector.')
end

% select the desired crossing times
if numel(interval) == 1
  sel = bt.tcross <= interval;
else
  sel = bt.tcross >= interval(1) & bt.tcross <= interval(2);
end

bt.tcross = bt.tcross(sel);
bt.word = bt.word(sel);
