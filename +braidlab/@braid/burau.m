function m = burau(b,t)
%BURAU   The Burau matrix representation of a braid.
%   M = BURAU(B,T) returns the reduced Burau matrix representation for the
%   braid B, with Burau parameter T.  Here T is a complex number with |T|=1
%   (default T=-1).
%
%   M = BURAU(B,T), where T is a Laurent polynomial class object, returns
%   the Burau representation as a cell array with Laurent polynomial
%   entries.  With the wavelet toolbox, use BURAU(B,laurpoly(1,1)).
%
%   M = BURAU(B,'abs') returns the matrix of the "absolute value" monoid,
%   where every nonzero entry of the Burau matrices of the standard braid
%   generators are set to one, before multiplying them together.  The
%   spectral radius of this matrix is an upper bound on the braid's
%   dilatation.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY, LAURPOLY.

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

if isnumeric(t)
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
else
  % t is not numeric: use a cell array.
  % Multiplication of numeric type by t must be defined.
  m = num2cell(eye(n-1));
  for sig = b.word(end:-1:1)
    i = abs(sig);
    if sig > 0
      for q = 1:n-1
	if i-1 > 0, m{i-1,q} = m{i-1,q} - t*m{i,q}; end
	if i+1 < n, m{i+1,q} = -m{i,q} + m{i+1,q}; end
	m{i,q} = -t*m{i,q};
      end
    else
      for q = 1:n-1
	if i-1 > 0, m{i-1,q} = m{i-1,q} - m{i,q}; end
	if i+1 < n, m{i+1,q} = -1/t*m{i,q} + m{i+1,q}; end
	m{i,q} = -1/t*m{i,q};
      end
    end
  end
end
