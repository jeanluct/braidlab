function out = assertmex(functionname)
%ASSERTMEX   Assert that MEX file exists.
%   ASSERTMEX(functionname) Checks that a mex file "functionname" exists. If
%   it does not exist, the function throws BRAIDLAB:noMEX error.
%
%   OUT = ASSERTMEX(functionname) Returns TRUE if mex file
%   "functionname" exists and FALSE otherwise. No errors are thrown.
%
%   ... = ASSERTMEX; Same as above, except the desired functionname is
%   detected by checking call stack. This can be useful in development
%   stages, but final versions of code should specify function name
%   explicitly to speed up the code.
%
%   Consider also invoking the function as assertmex(mfilename) if
%   the calling function is the first function in an m-file.

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

if nargin < 1
  [ST,~] = dbstack(1);
  functionname = ST(1).name;
end

if nargout < 1
  if exist(functionname,'file') ~= 3
    throw(braidlab.util.NoMEXException(functionname));
  end
else
  out = (exist(functionname,'file') == 3);
end
