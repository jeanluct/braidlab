function b = taffy(ptype,projang)
%TAFFY   Braid of taffy puller with 3,4,5,6 rods.
%   B = TAFFY(PTYPE), where PTYPE is one of
%
%     '3rods', '4rods', '4rods-alt', '5rods', '6rods'
%
%   returns the braid B of the taffy puller PTYPE.
%
%   TAFFY(PTYPE,PROJANG) specifies the projection angle PROJANG for
%   computing the braid (default 0).
%
%   See also BRAIDLAB.BRAID, BRAIDLAB.BRAID.BRAID.

import braidlab.*

if nargin < 1, ptype = '3rods'; end
if nargin < 2, projang = 0; end

% If ptype is a number, use that as the number of rods.
if ~ischar(ptype), ptype = sprintf('%drods',ptype); end

% Parameters or rods and orbits.
npts = 200; r = .75; rodr = .05;

gray = [.8 .8 .8];
th = linspace(0,2*pi,npts); th = th(end:-1:1);

switch lower(ptype)
 case {'3rod','3rods'}
  % The classic 3-rod taffy puller has counter-rotating rods.
  n = 3;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(i*(th-pi));
  z(:,2) = 0;
  z(:,3) = .5 + r*exp(-i*(th-pi));
  cl = {'r' gray 'b'};
 case {'4rods'}
  % For 4 rods, co-rotating.
  % This is the 'real' 4-pronged taffy puller.
  %
  % The rods on the small-radius trajctories behave as a fixed rod.
  n = 4;
  z = zeros(npts,n);
  r0 = .5*r;
  z(:,1) = 0 + r*exp(i*(th-pi));
  z(:,2) = 0 + r0*exp(i*th);
  z(:,3) = 1 + r*exp(i*th);
  z(:,4) = 1 + r0*exp(i*(th-pi));
  cl = {'r' 'r' 'b' 'b'};
 case {'4rods-alt'}
  % For 4 rods, co-rotating.
  %
  % Replace the moving rods by fixed rods.
  n = 4;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 1 + r*exp(i*th);
  z(:,4) = 1;
  cl = {'r' gray 'b' gray};
 case {'5rods'}
  % For 5 rods, insert one in the middle.  Doesn't change the entropy.
  n = 5;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 1 + r*exp(i*th);
  z(:,4) = 1;
  z(:,5) = .5*ones(size(z(:,1)));
  cl = {'r' gray 'b' gray 'm'};
 case {'6rods'}
  % For 6 rods, make it a 'double-puller'.
  n = 6;
  z = zeros(npts,n);
  z(:,1) = 0 + r*exp(i*(th-pi));
  z(:,2) = 0;
  z(:,3) = 1 + r*exp(i*th);
  z(:,4) = 1;
  z(:,5) = 0 + r*exp(i*th);
  z(:,6) = 1 + r*exp(i*(th-pi));
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

XY = zeros(npts,2,n);
XY(:,1,:) = real(z); XY(:,2,:) = imag(z);

b = braid(XY,projang);
