function XYc = closure(XY,ctype)
%CLOSURE   Force closure of a set of trajectories to make a physical braid.
%   XYC = CLOSURE(XY) or XYC = CLOSURE(XY,'Xproj') takes the particle
%   trajectory data in XY and appends the initial positions to the end of
%   the list.  The order is chosen so that no new crossings are created
%   (when projected along the X axis).  The data format is
%   XY(TIMESTEP,COORD,PARTICLES).
%
%   XYC = CLOSURE(XY,'Pure') closes the trajectories to make a pure braid,
%   that is, such that the strings return to their initial position.
%
%   XYC = CLOSURE(XY,'MinDist') closes the trajectories to minimize the sum
%   of the Euclidean distances between the final and initial points.  This
%   uses Markus Buehren's implementation of the Hungarian algorithm for the
%   optimal assigment problem.
%   (http://www.mathworks.com/matlabcentral/fileexchange/6543)
%
%   XYC = CLOSURE(XY,PERM) closes the braid so that final points are
%   linked according to permutation PERM.
%
%   See also BRAID, BRAID.BRAID, BRAID.ISPURE.

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

% Currently, the method of closure is tightly related to the axis of
% projection.  A better method might be to minimize the L^2 norm of
% distances between the final points and the starting points.

if nargin < 2
  ctype = 'Xproj';
end

XYnew = zeros(size(XY(1,:,:)));

if ~ischar(ctype)
  if length(unique(ctype)) ~= length(ctype)
    error('BRAIDLAB:closure:badarg','Second argument must be a permutation.')
  end
  XYnew(1,:,:) = XY(1,:,ctype);
else
  switch lower(ctype)

   case 'xproj'
    % Find the initial order of the particles.
    [~,I0] = sort(squeeze(XY(1,1,:)));
    % Find the final order of the particles.
    [~,I1] = sort(squeeze(XY(end,1,:)));
    XYnew(1,:,I1) = XY(1,:,I0);

   case 'yproj'
    % Find the initial order of the particles.
    [~,I0] = sort(squeeze(XY(1,2,:)));
    % Find the final order of the particles.
    [~,I1] = sort(squeeze(XY(end,2,:)));
    XYnew(1,:,I1) = XY(1,:,I0);

   case 'pure'
    % Find the initial order of the particles.
    [~,I0] = sort(squeeze(XY(1,1,:)));
    XYnew(1,:,I0) = XY(1,:,I0);

   case 'mindist'
    n = size(XY,3);
    X0 = XY(1,:,:);
    X1 = XY(end,:,:);
    % Create matrix of distances.
    D = zeros(n,n);
    for i = 1:n
      for j = 1:n
        D(i,j) = norm(X1(1,:,i)-X0(1,:,j));
      end
    end
    % Solve the optimal assignment problem.
    perm = braidlab.util.assignmentoptimal(D);
    XYnew(1,:,:) = XY(1,:,perm);

   otherwise
    error('BRAIDLAB:closure:badarg','Unknown closure type.')
  end
end

XYc = [XY; XYnew];
