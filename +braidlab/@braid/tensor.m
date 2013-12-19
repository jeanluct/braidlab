function c = tensor(a,b)
%TENSOR   Tensor product of two braids.
%   C = TENSOR(A,B) returns the tensor product of the braids A and B, which
%   is the braid obtained by putting A and B side-by-side, with A on the
%   left.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.MTIMES.

n1 = a.n;
n2 = b.n;

sg = sign(b.word);
idx = abs(b.word) + n1;  % re-index generators of b2

c = braidlab.braid([a.word idx.*sg],n1+n2);
