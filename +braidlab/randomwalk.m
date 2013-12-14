function X = randomwalk(n,N,eps,opts)
%RANDOMWALK   Random walks in two dimensions.
%   XY = RANDOMWALK(N,K,EPS) generates N random walks of K steps of size EPS
%   on the unit square.  XY has size [K+1 2 N].  The random walkers are
%   reflected when they hit the boundaries.
%
%   XY = RANDOMWALK(N,K,EPS,DOMAIN), where DOMAIN is 'disk', 'plane', or
%   'square', specifies the shape of the domain.  Reflecting boundary
%   conditions are applied at the boundaries.
%
%   XY = RANDOMWALK(X0,K,EPS,...) uses the N initial particle positions in
%   the vector X0, of size [2 N], one column per particle.
%
%   See also BRAID, BRAID.BRAID.

% TODO:
%
% 'brownian': choose stepsize from normal distribution.  Normalize
% eps to have same diffusion constant as random walk?
%
% 'lattice': eps specifies the spacing.
%

if isscalar(n)
  if n < 1
    error('BRAIDLAD:randomwalk:badarg','Need at least one particle.')
  end
elseif size(n,1) ~= 2
  error('BRAIDLAD:randomwalk:badarg','Vector X0 should have two rows.')
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

% Call MEX file.
switch lower(opts)
 case 'plane'
  if isscalar(n)
    r2 = rand(1,n); th = rand(1,n);
    X0 = [r2.*cos(th);r2.*sin(th)];
  else
    X0 = n;
  end
  X = randomwalk_helper(X0,N,eps,0);
 case {'square','box'}
  if isscalar(n)
    X0 = rand(2,n);
  else
    X0 = n;
  end
  X = randomwalk_helper(X0,N,eps,1);
 case 'disk'
  if isscalar(n)
    r2 = rand(1,n); th = rand(1,n);
    X0 = [r2.*cos(th);r2.*sin(th)];
  else
    X0 = n;
  end
  X = randomwalk_helper(X0,N,eps,2);
 otherwise
  error('BRAIDLAD:randomwalk:badarg','Unknown option %s.',opts)
end
