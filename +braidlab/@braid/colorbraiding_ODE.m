function [varargout] = colorbraiding_ODE(func,tspan,XY0)
%COLORBRAIDING_ODE   Find braid generators from trajectory ODE.

% TODO: projection angle, pass optional parameters to ODE45.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

validateattributes(tspan,{'numeric'}, ...
                   {'real','finite','nonnan'}, ...
                   'BRAIDLAB.braid.colorbraiding_ODE','tspan',2);

% The two rows of XY0 are the X and Y coordinates.
validateattributes(XY0,{'numeric'}, ...
                   {'real','finite','nonnan','nrows',2}, ...
                   'BRAIDLAB.braid.colorbraiding_ODE','XY0',3);

n = size(XY0,1); % number of punctures

%if nargin < 4
  % Default projection line is X axis.
  proj = 0;
%end

%delta = braidlab.prop('BraidAbsTol');

% Rotate coordinates according to angle proj.  Note that since the
% projection line is supposed to be rotated counterclockwise by proj, we
% rotate the data clockwise by proj.
if proj ~= 0, XY0 = rotate_data_clockwise(XY0,proj); end
