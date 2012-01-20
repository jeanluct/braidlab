function up = nongrowingloops(br,n,imin,imax,gr)
%NONGROWINGLOOPS   Apply generators to loops and keep only non-growing ones.
%   L = NONGROWINGLOOPS(B,VMIN,VMAX) applies the braid B to a list of loops
%   with indices bounded from below by the vector VMIN, and from above by
%   the vector VMAX.  L is an array of loops that contains only the
%   non-growing loops, that is, those that do not grow exponentially under
%   the action of B.
%
%   L = NONGROWINGLOOPS(B,N,IMIN,IMAX) applies B to all loops for N particles,
%   where the loop coordinates are all bounded by the scalars IMIN and IMAX.
%
%   L = NONGROWINGLOOPS(B,...,MAXGROWTH) discards loops whose length has grown
%   by a factor greater than MAXGROWTH (default 3).

% TODO: Make part of braid class.  Add threshold for "non-growing"?

badbounds = 'Lower bounds must be less than or equal to upper.';

% If the input br is a braid object, convert it to a vector of generators.
if isa(br,'braidlab.braid'), br = double(br.word); end

grdef = 3;  % default MAXGROWTH is 3

if ~isscalar(n)
  % n is a vector: so it specifies VMIN; imin is VMAX and imax is MAXGROWTH.
  if any(n > imin), error(badbounds); end
  if nargin < 4, imax = grdef; end
  up = braidlab.loop(nongrowingloops_helper(br,n,imin,imax).');
  return
end

if any(imin > imax), error(badbounds); end
if nargin < 5, gr = grdef; end

N = 2*n-4;

% Apply generators to all loops, and return an array of coordinates of
% non-growing loops.
up = nongrowingloops_helper(br,imin*ones(1,N),imax*ones(1,N),gr).';
up = braidlab.loop(up);
