function test_colorbraiding_ODE()

import braidlab.*

n = 3;
omega = 1;
tmax = 20;

f = @(t,X) rigid(t,X,omega);

XY0 = zeros(2,n);
ang = .2;
XY0(1,:) = cos(ang)*(1:n);
XY0(2,:) = sin(ang)*(1:n);
rng('default')
XY0 = XY0 + rand(size(XY0));

b = braid(f,[0 tmax],XY0);

%=======================================================================
function dX = rigid(t,X,omega)

dX(1,:) = omega*X(2,:);
dX(2,:) = -omega*X(1,:);
