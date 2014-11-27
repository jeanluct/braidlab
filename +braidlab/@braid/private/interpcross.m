function [tc,dY] = interpcross(t,X,Y,itc,p1,p2)
%INTERPCROSS   Interpolate a crossing.
%   [TC,DY] = INTERPCROSS(T,X,Y,ITC,P1,P2) is a helper function for
%   GENCROSS.  The input is the data T,X,Y (described in the help for
%   GENCROSS); the index ITC of the time of crossing (i.e., the particles
%   cross between T(ITC) and T(ITC+1); and the indices P1 and P2 of the two
%   particles that are crossing.  INTERPCROSS returns the interpolated
%   crossing time TC, as well as DY (the sign of the difference in Y
%   coordinates) which determines the sign of the generator.  ITC can also
%   be passed as a vector, in which case TC and DY will also be vectors.

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

if size(t,1) < size(t,2), t = t.'; end % Make sure t is a column vector.

% Refine crossing time and position (linear interpolation).
dt = t(itc+1) - t(itc);  % Time interval.

% Particle velocities in that interval.
U1 = (X(itc+1,p1) - X(itc,p1)) ./ dt;
V1 = (Y(itc+1,p1) - Y(itc,p1)) ./ dt;
U2 = (X(itc+1,p2) - X(itc,p2)) ./ dt;
V2 = (Y(itc+1,p2) - Y(itc,p2)) ./ dt;

% Interpolated crossing time and Y coordinates.
dtc = -(X(itc,p2) - X(itc,p1)) ./ (U2-U1);
tc = t(itc) + dtc;
Y1c = Y(itc,p1) + dtc.*V1;
Y2c = Y(itc,p2) + dtc.*V2;
dY = sign(Y1c-Y2c);

% The sign of Y1c-Y2c determines if the crossing is g or g^-1.
if any(dY == 0)
  error('BRAIDLAB:interpcross:cantresolve', ...
        'Can''t resolve sign of generator -- increase resolution.');
end
