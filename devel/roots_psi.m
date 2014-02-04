function e = roots_psi(n)
%ROOTS_PSI   Roots of low-entropy psi braids.
%   E = ROOTS_PSI(N) returns the roots of the Nth low-entropy braid psi,
%   created with braid('psi',N).  The roots are sorted in descending
%   order of magnitude.

% Polynomials from Venzke's thesis, page 53.
c = zeros(1,n+1);
c(1) = 1; c(n+1) = 1;
if mod(n,2) == 1
  k = (n-1)/2;
  c(n+1-(k+1)) = -2; c(n+1-(k)) = -2;
elseif mod(n,4) == 0
  k = n/4;
  c(n+1-(2*k+1)) = -2; c(n+1-(2*k-1)) = -2;
elseif mod(n,8) == 2
  k = (n-2)/8;
  c(n+1-(4*k+3)) = -2; c(n+1-(4*k-1)) = -2;
elseif mod(n,8) == 6
  k = (n-6)/8;
  c(n+1-(4*k+5)) = -2; c(n+1-(4*k+1)) = -2;
end

e = roots(c);

% Sort starting with largest magnitude.
[~,i] = sort(abs(e),'descend');
e = e(i);
