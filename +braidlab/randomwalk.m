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
%   See also BRAID, BRAID.BRAID.

% TODO:
%
% 'brownian': choose stepsize from normal distribution.  Normalize
% eps to have same diffusion constant as random walk?
%
% 'lattice': eps specifies the spacing.
%

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

% Call MEX file.
switch lower(opts)
 case 'plane'
  X = randomwalk_helper(n,N,eps,0);
 case {'square','box'}
  X = randomwalk_helper(n,N,eps,1);
 case 'disk'
  X = randomwalk_helper(n,N,eps,2);
 otherwise
  error('BRAIDLAD:randomwalk:badarg','Unknown option %s.',opts)
end
