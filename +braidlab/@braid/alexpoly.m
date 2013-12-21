function p = alexpoly(b)
%ALEXPOLY   Alexander polynomial of a braid.
%   P = ALEXPOLY(B) returns the Alexander polynomial (or Alexander-Conway
%   polynomial) of the closure of the braid B.
%
%   The Alexander polynomial is a Laurent polynomial (it has negative as
%   well as positive powers), which is represented using the Matlab
%   wavelet toolbox class 'laurpoly'.
%
%   Example: the trefoil knot is the closure of sigma_1^3.  Its Alexander
%   polynomial is
%
%   >> alexpoly(braid([1 1 1]))
%
%   ans(z) = + z^(+1) - 1 + z^(-1)
%
%   Reference:
%
%   Weisstein, Eric W. "Alexander Polynomial." From MathWorld -- A Wolfram
%   Web Resource. http://mathworld.wolfram.com/AlexanderPolynomial.html
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY, BRAID.BURAU, LAURPOLY.

if exist('laurpoly') ~= 2
  error('BRAIDLAB:braid:alexpoly:notoolbox',...
	'Wavelet toolbox (laurpoly) doesn''t appear to be installed.')
end

% Compute reduced Burau representation of the braid.
bu = burau(b,laurpoly(1,1));

n = b.n;

for i = 1:n-1, bu{i,i} = bu{i,i} - 1; end

num = (-1)^(n-1)*det(bu);
denom = laurpoly(ones(1,n),n-1);

% Long division of Laurent polynomials.  They always divide each other exactly.
p = mldivide(num,denom);

% Balance polynomial so p(z) = p(1/z).
pp = mldivide(reflect(p),p);
if ~ismonomial(pp)
  error('BRAIDLAD:braid:alexpoly:notmonomial',...
	'p(z) = p(1/z) cannot be enforced.')
end
deg = get(pp,'maxDEG');
p = p * laurpoly(1,deg/2);
