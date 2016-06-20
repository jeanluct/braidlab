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

n = size(XY0,2); % number of punctures

%if nargin < 4
  % Default projection line is X axis.
  proj = 0;
%end

%delta = braidlab.prop('BraidAbsTol');

% Rotate coordinates according to angle proj.  Note that since the
% projection line is supposed to be rotated counterclockwise by proj, we
% rotate the data clockwise by proj.
if proj ~= 0, XY0 = rotate_data_clockwise(XY0,proj); end

debugmsg('colorbraiding_ODE: Search for crossings between pairs of strings');

for I = 1:n
  debugmsg([num2str(I) '/' num2str(n)],2) % Counter to monitor progress
  for J = I+1:n
    % Create extended function to integrate particles I & J together.
    XY02 = [XY0(:,I);XY0(:,J)];
    func2 = @(t,XY2) [func(t,XY2(1:2,:));func(t,XY2(3:4,:))];

    % Integrate, recording events when the particles cross.
    opts = [];
    opts = odeset(opts,'Events',@paircross_event);
    [~,~,tc,XY2c,cdir] = ode45(func2,tspan,XY02,opts);

    dY = XY2c(:,2) - XY2c(:,4);
    icrIJ = find(cdir == 1);
    cross_cell{I,J} = [tc(icrIJ) sign(dY(icrIJ))];
    icrJI = find(cdir == 2);
    cross_cell{J,I} = [tc(icrJI) -sign(dY(icrJI))];
  end
end

[gen,tcr] = sortcross2gen(n,sortcross(cross_cell));
%keyboard

varargout{1} = braidlab.braid(gen,n);
if nargout > 1, varargout{2} = tcr; end

%==========================================================================
function[value,isterminal,direction] = paircross_event(t,XY2)

% Difference between the X coordinates of the two particles.
value = (XY2(1) - XY2(3))*[1;1];
isterminal = [0;0];
% Record left-to-right and right-to-left interchanges separately.
direction = [1;-1];
