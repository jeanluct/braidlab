function obj = subsasgn(obj,s,val)
%SUBSASGN   Subscript indexing with assignment for loops.
%
%   This is a method for the LOOP class.
%   See also LOOP.

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

if ~isempty(obj) && ~isscalar(obj)
  error('BRAIDLAB:loop:subsasgn:notscalar', ...
        ['Loop object must be a scalar... see ''help loop.loop''' ...
         ' for how to create multiple loops.'])
end

if isempty(s) && strcmp(class(val),'braidlab.loop')
  obj = val;
end

switch s(1).type
  case '.'
    % Use the built-in subsref for dot notation
    obj = builtin('subsasgn',obj,s,val);
  case '()'
    if length(s(1).subs) > 1
      error('BRAIDLAB:loop:subsasgn','Cannot use more than one index.')
    end
    if length(s) < 2
      if ~strcmp(class(val),'braidlab.loop')
        error('BRAIDLAB:loop:subsasgn:needscalar', ...
              'Can only assign a scalar loop.')
      end
      idx = s(1).subs{1};
      if isempty(obj)
        % Create the object, since it's empty.
        obj = braidlab.loop(zeros(idx,size(val.coords,2)),'bp',val.basepoint);
      else
        % Make sure loops have same basepoint.
        if obj.basepoint ~= val.basepoint
          error('BRAIDLAB:loop:subsasgn:basepoint', ...
                'Loops must have same basepoint (%g ~= %g).', ...
                obj.basepoint,val.basepoint)
        end
      end
      % Overwrite an existing row.
      obj.coords(idx,:) = val.coords;
      return
    elseif length(s) < 4
      if isempty(obj)
        error('BRAIDLAB:loop:subsasgn:emptyobj', ...
              'Object is empty... not sure this should happen.')
      end
      if ~strcmp(class(obj.coords),class(val))
        error('BRAIDLAB:loop:subsasgn:badtype', ...
              'Array must be of same type.')
      end
      idx = s(1).subs{:};
      if ~(s(2).type == '.' && strcmp(s(2).subs,'coords'))
        error('BRAIDLAB:loop:subsasgn:badref', ...
              'Not a supported subscripted reference.')
      end
      if length(s) > 2
        if ~strcmp(s(3).type,'()')
          error('BRAIDLAB:loop:subsasgn:badref', ...
                'Not a supported subscripted reference.')
        end
        if length(s(3).subs) > 1
          error('BRAIDLAB:loop:subsasgn:badindex', ...
                'Too many indices on coords.')
        end
        idx2 = s(3).subs{:};
      else
        idx2 = ':';
      end
      obj.coords(idx,idx2) = val;
      return
    else
      % Maybe should error here?
      warning('BRAIDLAB:loop:subsasgn:unsure', ...
              'Not sure if we should ever get here...')
      sref = builtin('subsasgn',obj,s,val);
    end
  case '{}'
    % No support for indexing using '{}'
    error('BRAIDLAB:loop:subsasgn:badref', ...
          'Not a supported subscripted reference.')
end
