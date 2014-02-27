function d = diag(M,k)
%DIAG   Diagonal vpi matrices and diagonals of a vpi matrix.
%   DIAG(V,K) when V is a vector of vpi integers with N components is a
%   square matrix of vpi's of order N+ABS(K) with the elements of V on the
%   K-th diagonal. K = 0 is the main diagonal, K > 0 is above the main
%   diagonal and K < 0 is below the main diagonal.  If omitted, K defaults
%   to 0.
%
%   V = DIAG(M,K) when M is a vpi matrix returns a column vector V of vpi's
%   formed from the elements of the K-th diagonal of X.
%
%   DIAG(X) is the main diagonal of X. DIAG(DIAG(X)) is a diagonal matrix.
%
%   See also VPI.VPI.

if nargin < 2, k = 0; end

if any(size(M) == 1)
  if k ~= 0, error('Option not supported yet.'); end
  mm = max(size(M));
  d = vpi(zeros(mm));
  for i = 1:mm, d(i,i) = M(i); end
  return
end

m = size(M,1); n = size(M,2);
mm = min(m,n);

if m ~= n, error('Nonsquare matrices not yet supported.'); end

if abs(k) >= mm, d = []; return; end

if k >= 0
  for i = 1:mm-k, d(i) = M(i,k+i); end
else
  for i = 1:mm-abs(k), d(i) = M(abs(k)+i,i); end
end
