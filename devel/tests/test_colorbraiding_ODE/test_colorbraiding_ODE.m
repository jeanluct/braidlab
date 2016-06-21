function b = test_colorbraiding_ODE()

global BRAIDLAB_braid_nomex
BRAIDLAB_braid_nomex = 1;

import braidlab.*

n = 10;
omega = 1;
tmax = 20;

f = @(t,X) rigid(t,X,omega);

% Initial condition.
XY0 = zeros(2,n);
ang = 0;
XY0(1,:) = cos(ang)*(1:n);
XY0(2,:) = sin(ang)*(1:n);
rng('default')
XY0 = XY0 + .001*rand(size(XY0));

% Integrate some trajectories at discrete times.
t = linspace(0,tmax,101);
XY = zeros(length(t),2,n);
for i = 1:n
  [~,XY1] = ode45(f,t,XY0(:,i));
  XY(:,:,i) = XY1;
end

% Construct braid from discretized trajectories.
b0 = databraid(XY,t);

% Construct braid directly from ODE.
b = braid(f,[0 tmax],XY0);

% Check if the braids match.
if (b == b0)
  fprintf('\nBraids match!\n')
else
  fprintf('\n*** Braids don''t match...\n')
end

%=======================================================================
function dX = rigid(t,X,omega)

dX(1,:) = -omega*X(2,:);
dX(2,:) = omega*X(1,:);
