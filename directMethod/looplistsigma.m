function up = looplistsigma(ii,n,imin,imax)
%LOOPLISTSIGMA   Apply generators to loops, keep only non-growing ones.
%   L = LOOPLISTSIGMA(B,VMIN,VMAX) applies the braid B to a list of loops
%   with indices bounded from below by the vector VMIN, and from above by
%   the vector VMAX.  L is an array that contains only the non-growing
%   loops, that is, those that do not grow exponentially under the action
%   of B.
%
%   L = LOOPLISTSIGMA(B,N,IMIN,IMAX) applies B to all loops for N particles,
%   where the loop coordinates are all bounded by the scalars IMIN and IMAX.

% TODO: Make part of braid class.  Add threshold for "non-growing"?

badbounds = 'Lower bounds must be less than or equal to upper.';

% If the input ii is a braid object, convert it to a vector of generators.
if isa(ii,'braidlab.braid')
  sigma = double(ii.word);
else
  sigma = ii;
end

if length(n) > 1
  if any(n > imin), error(badbounds); end
  up = looplistsigma_helper(sigma,n,imin).';
  return
end

if any(imin > imax), error(badbounds); end
N = 2*n-4;

% Apply generators to all loops, and return an array of non-growing loop
% coordinates.
dyn = looplistsigma_helper(sigma,imin*ones(1,N),imax*ones(1,N)).';

% Convert to an array of loops.
up = braidlab.loop(dyn);
