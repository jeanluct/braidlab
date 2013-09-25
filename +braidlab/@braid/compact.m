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
%   Note that COMPACT doesn't guarantee the shortest length, since this is a
%   co-NP-complete problem (Ref. [1]).  But it uses the algorithm in
%   Ref. [2] which is known to do pretty well at shortening braids.
%
%   References
%
%   [1] M. S. Paterson and A. A. Razborov, "The set of minimal braids is
%   co-NP-complete," J. Algorithms 12 (1991), 393-408.
%
%   [2] P. D. Bangert, M. A. Berger and R. Prandi, "In search of minimal
%   random braid configurations," J. Phys. A 35 (2002), 43-59.
%
%   This is a method for the BRAID class.
%   See also BRAID.

if istrivial(b),     
    c = braidlab.braid([], b.n); 
    return; 
end

bc = compact_helper(b.word);

c = braidlab.braid(bc,b.n);
