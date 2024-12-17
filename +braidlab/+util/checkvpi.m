function checkvpi
%CHECKVPI   Check if Variable Precision Intergers library is on path.
%   CHECKVPI looks for the 'vpi' class on Matlab's path, and if it doesn't
%   find it tries to add it to the path, assuming the default installation
%   of braidlab.
%
%   VPI was written by John D'Errico.
%   https://www.mathworks.com/matlabcentral/fileexchange/22725-variable-precision-integer-arithmetic.
%   See braidlab/extern/VariablePrecisionIntegers/license.txt
%
%   See also VPI, BRAID.LOOPCOORDS, LOOP.LOOP.

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

% Check if variable precision integers library is available.
if ~exist('vpi','file')
  % No VPI... try to add the path.
  blbase = fileparts(fileparts(fileparts(which('braidlab.util.checkvpi'))));
  addpath(fullfile(blbase,'/extern/VariablePrecisionIntegers'))
  if ~exist('vpi','file')
    % For some reason this didn't work.
    error('BRAIDLAB:checkvpi:novpi',...
          ['vpi type not on path.  Try ''addpath ' ...
           'extern/VariablePrecisionIntegers'' from braidlab folder.'])
  end
end
