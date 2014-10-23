% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://bitbucket.org/jeanluc/braidlab/
%
%   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                             Marko Budisic         <marko@math.wisc.edu>
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

asp = [1 2 1];
fs = 22;

b = braid([1 -2]); cycle(b,'plot')
pbaspect(asp)
set(gca,'FontSize',fs)
print -dpdf efflinact1

b = braid([1 2 3]); cycle(b,'plot')
pbaspect(asp)
set(gca,'FontSize',fs)
print -dpdf efflinact2

b = braid('psi',11); cycle(b,'plot')
pbaspect(asp)
set(gca,'FontSize',fs)
print -dpdf efflinact3
