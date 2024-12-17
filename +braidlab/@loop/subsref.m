function [varargout] = subsref(obj,s)
%SUBSREF   Subscript indexing for loops.
%
%   This is a method for the LOOP class.
%   See also LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <mbudisic@gmail.com>
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
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

if ~isempty(obj) && ~isscalar(obj)
  error('BRAIDLAB:loop:subsref:notscalar', ...
        ['Loop object must be a scalar... see ''help loop.loop''' ...
         ' for how to create multiple loops.'])
end

switch s(1).type
  case '.'
    % Use the built-in subsref for dot notation
    [varargout{1:nargout}] = builtin('subsref',obj,s);
  case '()'
    if length(s(1).subs) > 1
      error('BRAIDLAB:loop:subsref:toomanyind', ...
            'Cannot use more than one index.')
    end
    idx = s(1).subs{1};
    objrow = braidlab.loop(obj.coords(idx,:),'bp',obj.basepoint);
    if nargout > 0, varargout{1} = objrow; end
    s(1) = [];
    if ~isempty(s)
      % If there is stuff left over, continue evaluating.
      [varargout{1:nargout}] = builtin('subsref',objrow,s);
      return
    end
    % Output something anyways if no output args specified.
    if nargout == 0, varargout{1} = objrow; end
  case '{}'
    % No support for indexing using '{}'
    error('BRAIDLAB:loop:subsref:badref', ...
          'Not a supported subscripted reference')
end
