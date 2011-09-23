function [varargout] = compact(b,t)
%COMPACT   Shorten a braid as much as possible.
%   C = COMPACT(B) attempts to shorten a braid B by using group properties,
%   and returns the shortened braid C.  The group relations are
%
%     S_i S_j = S_j S_i ,   |i-j| > 1
%
%     S_i S_(i+1) S_i = S_(i+1) S_i S_(i+1),   i = 1,..,n-2
%
%   where S_i, i = 1,..n-1 are the Artin generators.
%
%   [C,TC] = COMPACT(B,T) simultaneously updates the list of crossing times
%   T, and returns it as TC.
%
%   Note that COMPACT doesn't guarantee the shortest length.
%
%   See also BRAID.

if nargin > 1
  error('BRAIDLAB:compact:nargin','t arg not yet implemented.')
end

varargout{1} = braidlab.braid(compact_helper(b.word,b.n),b.n);
