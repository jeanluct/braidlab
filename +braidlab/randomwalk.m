function X = randomwalk(n,N,eps,opts)
%RANDOMWALK   Random walks in two dimensions.
%   XY = RANDOMWALK(N,K,EPS) generates N random walks of K steps of size EPS
%   on the unit square.  XY has size [K+1 2 N].  The random walkers are
%   reflected when they hit the boundaries.
%
%   XY = RANDOMWALK(N,K,EPS,DOMAIN), where DOMAIN is 'Disk', 'Plane', or
%   'Square', specifies the shape of the domain.  Reflecting boundary
%   conditions are applied at the boundaries.
%
%   XY = RANDOMWALK(X0,K,EPS,...) uses the N initial particle positions in
%   the vector X0, of size [2 N], one column per particle.
%
%   See also BRAID, BRAID.BRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

% TODO:
%
% 'Brownian': choose stepsize from normal distribution.  Normalize
% eps to have same diffusion constant as random walk?
%
% 'Lattice': eps specifies the spacing.
%

if isscalar(n)
  if n < 1
    error('BRAIDLAB:randomwalk:badarg','Need at least one particle.')
  end
elseif size(n,1) ~= 2
  error('BRAIDLAB:randomwalk:badarg','Vector X0 should have two rows.')
end

if N < 1
  error('BRAIDLAB:randomwalk:badarg','Need at least one step.')
end

if eps <= 0
  error('BRAIDLAB:randomwalk:badarg','Need EPS > 0.')
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
  error('BRAIDLAB:randomwalk:badarg','Unknown option %s.',opts)
end
