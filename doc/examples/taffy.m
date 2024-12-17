function b = taffy(ptype,projang)
%TAFFY   Braid of taffy puller with 3,4,5,6 rods.
%   B = TAFFY(PTYPE), where PTYPE is one of
%
%     '3rods', '4rods', '4rods-alt', '5rods', '6rods', '6rods-bad', '6rods-alt'
%
%   returns the braid B of the taffy puller PTYPE.
%
%   TAFFY(PTYPE,PROJANG) specifies the projection angle PROJANG for
%   computing the braid (default 0).
%
%   See also BRAIDLAB.BRAID, BRAIDLAB.BRAID.BRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

import braidlab.*

if nargin < 1, ptype = '3rods'; end
if nargin < 2, projang = 0; end

% If ptype is a number, use that as the number of rods.
if ~ischar(ptype), ptype = sprintf('%drods',ptype); end

% Parameters or rods and orbits.
npts = 200; r = .75; rodr = .05;

gray = [.8 .8 .8];
th = linspace(2*pi,0,npts);  % clockwise

switch lower(ptype)
 case {'3rod','3rods'}
  % The classic 3-rod taffy puller has counter-rotating rods.
  n = 3;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0;
  z(:,3) = .5 + r*exp(-1i*(th-pi));
  cl = {'r' gray 'b'};
 case {'4rods'}
  % For 4 rods, co-rotating.
  % This is the 'real' 4-pronged taffy puller.
  %
  % The rods on the small-radius trajectories behave as a fixed rod.
  n = 4;
  z = zeros(npts,n);
  r0 = .5*r;
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0 + r0*exp(1i*th);
  z(:,3) = 1 + r*exp(1i*th);
  z(:,4) = 1 + r0*exp(1i*(th-pi));
  cl = {'r' 'r' 'b' 'b'};
 case {'4rods-alt'}
  % For 4 rods, co-rotating.
  %
  % Replace the moving rods by fixed rods (topologically equivalent).
  n = 4;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 1 + r*exp(1i*th);
  z(:,4) = 1;
  cl = {'r' gray 'b' gray};
 case {'5rods'}
  % For 5 rods, insert one in the middle.  Doesn't change the entropy.
  n = 5;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 1 + r*exp(1i*th);
  z(:,4) = 1;
  z(:,5) = .5*ones(size(z(:,1)));
  cl = {'r' gray 'b' gray 'm'};
 case {'6rods'}
  % For 6 rods, insert fixed rods on axes of rotation.
  n = 6;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 1 + r*exp(1i*th);
  z(:,4) = 1;
  z(:,5) = 0 + r*exp(1i*th);
  z(:,6) = 1 + r*exp(1i*(th-pi));
  cl = {'r' gray 'b' gray 'r' 'b'};
 case {'6rods-bad'}
  % Alternate (bad) design for 6 rods.
  n = 6;
  z = zeros(npts,n);
  r0 = .5*r;
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 0 + r0*exp(1i*th);
  z(:,4) = 1;
  z(:,5) = 1 + r*exp(1i*th);
  z(:,6) = 1 + r0*exp(1i*(th-pi));
  cl = {'r' gray 'r' gray 'b' 'b'};
 case {'6rods-alt'}
  % Alternate design for 6 rods.
  n = 6;
  r = 1.2;
  z = zeros(npts,n);
  r0 = .3*r;
  z(:,1) = 0 + r*exp(1i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 0 + r0*exp(1i*th);
  z(:,4) = 1;
  z(:,5) = 1 + r*exp(1i*th);
  z(:,6) = 1 + r0*exp(1i*(th-pi));
  cl = {'r' gray 'b' gray 'r' 'b'};
end

clf

iq = ceil(npts/4)+1;
for j = 1:n
  if z(1,j) ~= z(2,j)
    % moving rod
    plot(real(z(:,j)),imag(z(:,j)),cl{j},'LineWidth',2)
    hold on
  end
end
% Plot arrow to indicate direction of motion.
for j = 1:n
  if z(1,j) ~= z(2,j)
    x1 = real(z(iq-1,j)); y1 = imag(z(iq-1,j));
    x2 = real(z(iq+1,j)); y2 = imag(z(iq+1,j));
    set(arrow([x1 y1],[x2 y2],'Length',15,'TipAngle',25,'BaseAngle',90),...
	'FaceColor',cl{j},'EdgeColor',cl{j});
  end
end
for j = 1:n
  % Plot rod at start.
  patch(real(z(1,j)) + rodr*cos(th),imag(z(1,j)) + rodr*sin(th),cl{j})
end
axis equal, hold off
ax = axis; axis(1.2*ax); axis off
set(gcf,'color','w')

if false, print('-dpdf',sprintf('taffy_%s.pdf',ptype)); end

b = braid(z,projang);
