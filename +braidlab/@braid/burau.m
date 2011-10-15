function m = burau(b,t)
%BURAU   The Burau matrix representation of a braid.
%   M = BURAU(B,T) returns the Burau matrix representation for the braid B,
%   with Burau parameter T (default T=-1).
%
%   M = BURAU(B,'abs') returns the matrix of the "absolute value" monoid,
%   where ever entry of the Burau matrices are taken in absolute value.  The
%   spectrial radius of this matrix is an upper bound on the braid's
%   dilatation.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.

if nargin < 2, t = -1; end

if ischar(t)
  if any(strcmp(lower(t),{'abs','monoid'}))
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

% Precompute the matrices.
B = cell(1,n-1); Bi = cell(1,n-1);
for i = 1:n-1
  m = speye(n-1);
  if (i-1 > 0) m(i-1,i) = -t; end
  m(i,i) = -t;
  if (i+1 < n) m(i+1,i) = afun(-1); end
  B{i} = m;

  m = speye(n-1);
  if (i-1 > 0) m(i-1,i) = afun(-1); end
  m(i,i) = -1/t;
  if (i+1 < n) m(i+1,i) = -1/t; end
  Bi{i} = m;
end

m = speye(n-1);
for sig = b.word;
  if sig > 0
    m = m*B{sig};
  else
    m = m*Bi{-sig};
  end
end

m = full(m);
