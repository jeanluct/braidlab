function h = unitball_loop( A, R)
%UNITBALL_LOOP Plot slices through unit balls of loop lengths.
%
%  A - two vectors spanning the slice through 2n-4 space
%  R - resolution of the grid used
%
%  Axes are orthonormalized before plotting.
%
% As an example, the following code cycles through random slices
% of loop space of braids of 30 strands:
%
% n = 30;
% while true;
%   S = rand(2*n-4,2);
%   h = unitball_loop(S, 200);
%   pause(0.05);
% end;

% number of punctures
n = size(A,1)/2+2;

% orthonormalize axes
[Q,~] = qr(A,0);

% generate a grid of loop coordinates
axgrid = linspace(-1/sqrt(n), 1/sqrt(n),R);
[X,Y] = meshgrid(axgrid);
PT = [X(:),Y(:)].';

% compute loops
L = nan(size(X));
LP = braidlab.loop( (Q*PT).' );

% styles of two distances
styles(1).dist=@intaxis;
styles(1).st = 'r-.';
styles(1).name = 'intaxis';

styles(2).dist=@minlength;
styles(2).st = 'b--';
styles(2).name = 'minlength';

% compute and plot unit balls
for s = styles
  Ls = s.dist(LP);
  L = reshape( Ls, size(X) );
  [~,h] = contour(X,Y,L,[1,1],s.st,'DisplayName',s.name);
  hold on;
end
hold off;
legend('Location','NorthEast');
title(sprintf('Random 2d slice through unit balls of loops around n = %d punctures',n));