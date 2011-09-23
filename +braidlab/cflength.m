function l = cflength(cf)
%CFLENGTH   Word length of left or right canonical form of a braid word.
%   L = CFLENGTH(CF) returns the length of a braid group word CF.  CF is a
%   structure representing the left or right canonical form, as returned by
%   CANFORM.
%
%   See also CANFORM, CFEQUAL.

n = cf.n;
Dl = n*(n-1)/2;  % The lengh of the half-twist Delta.

l = abs(cf.delta)*Dl + length(cell2mat(cf.factors));
