function wc = display_row(obj)
% Displays a row of loops.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

% Input should be at most a row-vector.
if size(obj,1) > 1
  error('BRAIDLAB:loop:display_row:badarg', ...
        'Input should be a row-vector of loops.')
end

% Get size of window.
sz = get(0, 'CommandWindowSize');

% Wrap lines to window size.
wc = textwrap({char(obj)},sz(1)-6);

for i = 1:length(wc)
  % Is there a parenthesis as the first character?  Then it is not
  % a wrapped line.
  wrapped = (wc{i}(1) ~= '(');
  % Indent rows.
  if i > 1 && wrapped
    wc{i} = ['      ' wc{i}];
  else
    wc{i} = ['   ' wc{i}];
  end
  % If the format is loose rather than compact, add a line break.
  if strcmp(get(0,'FormatSpacing'),'loose')
    if wrapped || i == length(wc)
      wc{i} = sprintf('%s\n',wc{i});
    end
  end
end
