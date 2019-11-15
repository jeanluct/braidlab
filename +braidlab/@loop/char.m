function str = char(obj)
%CHAR   Convert loop to string.
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.DISP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2019  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

if isscalar(obj)
  if ~isa(obj(1).coords,'vpi')
    objstr = num2str(obj.coords);
  else
    % The VPI num2str command is buggy on arrays.
    objstr = num2str(obj.coords(1));
    if obj.coords(1) < 0, objstr(1:3) = ''; else objstr(1:4) = ''; end
    for i = 2:length(obj.coords)
      oo = num2str(obj.coords(i)); oo(1:2) = '';
      objstr = [objstr oo]; %#ok<AGROW>
    end
  end
  nr = size(objstr,1); % number of rows
  if obj.basepoint
    if obj.basepoint == obj.totaln
      bp = '*';  % for standard basepoint (last puncture)
    else
      bp = ['*' num2str(obj.basepoint)];  % nonstandard basepoint
    end
  else
    bp = '';
  end
  str = [repmat('(( ',nr,1) objstr repmat([' ))' bp],nr,1)];
else
  str = [];
  if size(obj,1) > size(obj,2)
    for i = 1:size(obj,1)
      str = [str ; char(obj(i,:))]; %#ok<AGROW>
    end
  else
    str = char(obj(:,1));
    for i = 2:size(obj,2)
      objstr = char(obj(:,i));
      nr = size(objstr,1); % number of rows
      str = [str repmat('  ',nr,1) objstr]; %#ok<AGROW>
    end
  end
end
