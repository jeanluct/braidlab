function up = looplistsigma(ii,n,imin,imax)
%LOOPLISTSIGMA   Apply generators to loops.
%   U = LOOPLISTSIGMA(J,VMIN,VMAX) returns applies the sequence of
%   generators J to a list of loops with indices bounded from below by the
%   vector VMIN, and from above by the vector VMAX.
%
%   U = LOOPLISTSIGMA(J,N,IMIN,IMAX) applies J to all loops for N particles,
%   where the loop coordinates are each bounded by the scalars IMIN and
%   IMAX.

badbounds = 'Lower bounds must be less than or equal to upper.';

if length(n) > 1
  if any(n > imin), error(badbounds); end
  up = looplistsigma_helper(ii,n,imin).';
  return
end

if any(imin > imax), error(badbounds); end
N = 2*n-4;

up = looplistsigma_helper(ii,imin*ones(1,N),imax*ones(1,N)).';
