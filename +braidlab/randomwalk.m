function X = randomwalk(n,N,eps,opts)
%RANDOMWALK   Random walks on the unit square.
%   XY = RANDOMWALK(N,K,EPS) generates N random walks of K steps of size EPS
%   on the unit square.  XY has size [K+1 2 N].  The random walkers are
%   reflected when they hit the boundaries.
%
%   See also BRAID, BRAID.BRAID.

% TODO:
%
% 'brownian': choose stepsize from normal distribution.  Normalize
% eps to have same diffusion constant as random walk?
%
% 'lattice': eps specifies the spacing.
%
% circular domain.

if n < 1
  error('BRAIDLAD:randomwalk:badarg','Need at least one particle.')
end

if N < 1
  error('BRAIDLAD:randomwalk:badarg','Need at least one step.')
end

if eps <= 0
  error('BRAIDLAD:randomwalk:badarg','Need EPS > 0.')
end

if nargin < 4
  opts = 'square';
end

if 1
  % Call MEX file.
  switch lower(opts)
   case {'square','box'}
    X = randomwalk_helper(n,N,eps,0);
   case 'disk'
    X = randomwalk_helper(n,N,eps,1);
   otherwise
    error('BRAIDLAD:randomwalk:badarg','Unknown option %s.',opts)
  end
else

  % Particles are uniformly distributed in [0,1]^2.
  X0 = rand(1,2,n);

  % Displacement at random angle at each step.
  theta = 2*pi*rand(N,1,n);
  dX = eps*[cos(theta) sin(theta)];

  % Add up the displacements.
  X = cumsum([X0;dX]);

  % Reflect back into the interval [0,1] for each coordinate.
  X = mod((-1).^floor(X).*X,1);

end
