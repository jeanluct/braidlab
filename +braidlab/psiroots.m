function e = psiroots(n)
%PSIROOTS   Roots of low-entropy psi braids.
%   E = PSIROOTS(N) returns the roots of the polynomial of the Nth
%   low-entropy braid psi, created with braid('psi',N) for N > 4.  The
%   roots are sorted in descending order of magnitude.
%
%   For N <= 4 the roots are those of the lowest-entropy braids.
%
%   Reference:
%
%   R. Venzke, "Braid forcing, hyperbolic geometry, and pseudo-Anosov
%   sequences of low entropy," PhD Thesis (2008).
%
%   See also BRAID, BRAID.BRAID.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

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

% The degree of the n=3 polynomial should be 2.
if n == 3, e(2) = []; end
