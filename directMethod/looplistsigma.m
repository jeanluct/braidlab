function up = looplistsigma(br,n,imin,imax,gr)
%LOOPLISTSIGMA   Apply generators to loops, keep only non-growing ones.
%   L = LOOPLISTSIGMA(B,VMIN,VMAX) applies the braid B to a list of loops
%   with indices bounded from below by the vector VMIN, and from above by
%   the vector VMAX.  L is an array of loops that contains only the
%   non-growing loops, that is, those that do not grow exponentially under
%   the action of B.
%
%   L = LOOPLISTSIGMA(B,N,IMIN,IMAX) applies B to all loops for N particles,
%   where the loop coordinates are all bounded by the scalars IMIN and IMAX.
%
%   L = LOOPLISTSIGMA(B,...,MAXGROWTH) discards loops whose length has grown
%   by a factor greater than MAXGROWTH (default 3).

% TODO: Make part of braid class.  Add threshold for "non-growing"?

badbounds = 'Lower bounds must be less than or equal to upper.';

% If the input br is a braid object, convert it to a vector of generators.
if isa(br,'braidlab.braid'), br = double(br.word); end

if isvector(n)
  % n is a vector: so it specifies VMIN; imin is VMAX and imax is MAXGROWTH.
  if any(n > imin), error(badbounds); end
  if nargin < 4, imax = 3; end  % default MAXGROWTH is 3
  up = braidlab.loop(looplistsigma_helper(br,n,imin,imax).');
  return
end

if any(imin > imax), error(badbounds); end
if nargin < 5, gr = 3; end  % default MAXGROWTH is 3

N = 2*n-4;

% Apply generators to all loops, and return an array of non-growing loop
% coordinates.
dyn = looplistsigma_helper(br,imin*ones(1,N),imax*ones(1,N),gr).';

% Convert to an array of loops.
up = braidlab.loop(dyn);
