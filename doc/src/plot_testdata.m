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

load ../testsuite/testcases/testdata

cl = {'r' 'g' 'b' 'm'};

ii = 1:length(ti);
XY = XY(ii,:,:); ti = ti(ii);

figure(1)
clf
for k =1:4
  plot(XY(:,1,k),ti,cl{k}), hold on
end
xlabel('X')
ylabel('t')
pbaspect([.75 1 1])
axis tight
hold off
print -dpdf testdata_trajs

figure(2)
clf
for k =1:4
  plot3(XY(:,1,k),XY(:,2,k),ti,cl{k}), hold on
end
xlabel('X')
ylabel('Y')
zlabel('t')
pbaspect([.75 .75 1])
axis tight
hold off
print -dpdf testdata_trajs3
