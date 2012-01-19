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

% if the input J is a braid object we will convert the object into a vector
% of the sequence of generators

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

dyn = looplistsigma_helper(sigma,imin*ones(1,N),imax*ones(1,N)).';

% The conversion of to an array of loops that do not grow
% under the action of the generator sequence

up = braidlab.loop(dyn);

