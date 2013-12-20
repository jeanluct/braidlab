function m = burau(b,t)
%BURAU   The Burau matrix representation of a braid.
%   M = BURAU(B,T) returns the reduced Burau matrix representation for the
%   braid B, with Burau parameter T (default T=-1).
%
%   M = BURAU(B,'abs') returns the matrix of the "absolute value" monoid,
%   where every entry of the Burau matrices of the standard braid generators
%   are taken in absolute value, before multiplying them together.  The
%   spectral radius of this matrix is an upper bound on the braid's
%   dilatation.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.

if nargin < 2, t = -1; end

if ischar(t)
  if any(strcmpi(t,{'abs','monoid'}))
    t = -1;
    afun = @abs;
  else
    error('BRAIDLAB:braid:burau:badarg','Unrecognized string option.')
  end
else
  % Use identity function.
  afun = @(x) x;
end

n = b.n;

m = eye(n-1);
for sig = b.word(end:-1:1)
  i = abs(sig);
  if sig > 0
    for q = 1:n-1
      if i-1 > 0, m(i-1,q) = m(i-1,q) - t*m(i,q); end
      if i+1 < n, m(i+1,q) = afun(-1)*m(i,q) + m(i+1,q); end
      m(i,q) = -t*m(i,q);
    end
  else
    for q = 1:n-1
      if i-1 > 0, m(i-1,q) = m(i-1,q) + afun(-1)*m(i,q); end
      if i+1 < n, m(i+1,q) = -1/t*m(i,q) + m(i+1,q); end
      m(i,q) = -1/t*m(i,q);
    end
  end
end
