function e = psiroots(n,flag)
%PSIROOTS   Roots of low-entropy psi braids.
%   E = PSIROOTS(N) returns the roots of the polynomial of the Nth
%   low-entropy braid psi, created with braid('psi',N) for N > 4.  The
%   roots are sorted in descending order of magnitude.
%
%   For 3 <= N <= 4 the roots are those of the lowest-entropy braids.
%
%   E = PSIROOTS(N,'poly') returns the coefficients of the polynomial, in
%   Matlab vector form.
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

if nargin < 2, flag = 'roots'; end

if n < 3
  error('BRAIDLAB:psiroots:badarg','Need at least three strings.')
end

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

% The case n=6 is exceptional.
% Need to check: this gives the right dilatation, but is it the right
% polynomial?
if n == 6, c = [1 1 -1 -4 -4 -1 1 1]; end

switch lower(flag)
 case 'roots'
  e = roots(c);

  % Sort starting with largest magnitude.
  [~,i] = sort(abs(e),'descend');
  e = e(i);

  % The degree of the n=3 polynomial should be 2.
  if n == 3, e(2) = []; end

 case {'poly','polynomial','charpoly'}
  e = c;

 otherwise
  error('BRAIDLAB:psiroots','Unknown flag ''%s''',flag)

end
