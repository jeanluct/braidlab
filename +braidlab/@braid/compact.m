function c = compact(b)
%COMPACT   Shorten a braid as much as possible.
%   C = COMPACT(B) attempts to shorten a braid B by using group properties,
%   and returns the shortened braid C.  The group relations are
%
%     S(i) S(j) = S(j) S(i) ,   |i-j| > 1,   i,j = 1,..,n-1
%
%     S(i) S(i+1) S(i) = S(i+1) S(i) S(i+1),   i = 1,..,n-2
%
%   where S(i), i = 1,..n-1 are the Artin generators.
%
%   Note that COMPACT doesn't guarantee the shortest length.
%
%   This is a method for the BRAID class.
%   See also BRAID.

if isempty(b), c = b; return; end

bc = compact_helper(b.word);

c = braidlab.braid(bc,b.n);
