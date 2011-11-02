function X = randomwalk(n,N,eps)
%RANDOMWALK   Random walks on the unit square.
%   XY = RANDOMWALK(N,K,EPS) generates N random walks of K steps of size EPS
%   on the unit square.  XY has size [K 2 N].  The random walkers are
%   reflected when they hit the boundaries.
%
%   See also BRAID, BRAID.BRAID.

% Particles are uniformly distributed in [0,1]^2.
X0 = rand(1,2,n);

% Displacement at random angle at each step.
theta = 2*pi*rand(N,1,n);
dX = eps*[cos(theta) sin(theta)];

% Add up the displacements.
X = cumsum([X0;dX]);

% Reflect back into the interval [0,1] for each coordinate.
X = mod((-1).^floor(X).*X,1);
