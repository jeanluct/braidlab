function ul = looplist(n,imin,imax)
%LOOPLIST   Make a list of loops.
%   U = LOOPLIST(VMIN,VMAX) returns a list of loops with indices bounded
%   from below by the vector VMIN, and from above by the vector VMAX.
%
%   U = LOOPLIST(N,IMIN,IMAX) returns loops with N entries each bounded by
%   the scalars IMIN and IMAX.

badbounds = 'Lower bounds must be less than or equal to upper.';

if length(n) > 1
  if any(n > imin), error(badbounds); end
  ul = looplist_helper(n,imin);
  return
end

if any(imin > imax), error(badbounds); end

ul = looplist_helper(imin*ones(1,n),imax*ones(1,n));
