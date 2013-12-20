function p = alexpoly(b)
%ALEXPOLY   Alexander polynomial of a braid.
%   P = ALEXPOLY(B) returns the
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY, BRAID.BURAU, LAURPOLY.

% Compute reduced Burau representation of the braid.
bu = burau(b,laurpoly(1,1));

n = b.n;

for i = 1:n-1, bu{i,i} = bu{i,i} - 1; end

num = (-1)^(n-1)*detcell(bu);
denom = laurpoly(ones(1,n),n-1);

p = mldivide(num,denom);

% Balance polynomial so p(z) = p(1/z).
deg = get(mldivide(reflect(p),p),'maxDEG');
p = p * laurpoly(1,deg/2);
