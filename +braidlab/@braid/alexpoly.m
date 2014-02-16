function p = alexpoly(b,x)
%ALEXPOLY   Alexander polynomial of a braid.
%   P = ALEXPOLY(B) returns the Alexander polynomial (or Alexander-Conway
%   polynomial) of the closure of the braid B.
%
%   The Alexander polynomial is a Laurent polynomial (it has negative as
%   well as positive powers), which is represented by default using the
%   Matlab wavelet toolbox class 'laurpoly'.
%
%   Example: the trefoil knot is the closure of sigma_1^3.  Its Alexander
%   polynomial is
%
%   >> alexpoly(braid([1 1 1]))
%
%   ans(z) = + z^(+1) - 1 + z^(-1)
%
%   To use the symbolic toolbox instead (much slower), specify the
%   polynomial variable as a second argument:
%
%   >> alexpoly(braid([1 1 1]),sym('x'))
%
%   ans = x + 1/x - 1
%
%   Reference:
%
%   Weisstein, Eric W. "Alexander Polynomial." From MathWorld -- A Wolfram
%   Web Resource. http://mathworld.wolfram.com/AlexanderPolynomial.html
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY, BRAID.BURAU, LAURPOLY.

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

if nargin < 2
  if exist('laurpoly') == 2
    x = laurpoly(1,1);
  elseif exist('sym') == 2
    x = sym('x');
  else
    error('BRAIDLAB:braid:alexpoly:notoolbox',...
          ['Neither the wavelet toolbox (laurpoly) nor the symbolic toolbox' ...
           ' (sym) appear to be installed.'])
  end
end

% Compute reduced Burau representation of the braid.
bu = burau(b,x);
n = b.n;

switch class(x)
 case 'laurpoly'
  for i = 1:n-1, bu{i,i} = bu{i,i} - 1; end

  num = (-1)^(n-1)*det(bu);
  denom = laurpoly(ones(1,n),n-1);

  % Long division of Laurent polynomials. They always divide each other exactly.
  p = mldivide(num,denom);

  % Balance polynomial so p(z) = p(1/z).
  pp = mldivide(reflect(p),p);
  if ~ismonomial(pp)
    error('BRAIDLAB:braid:alexpoly:notmonomial',...
          'p(z) = p(1/z) cannot be enforced.')
  end
  deg = get(pp,'maxDEG');
  if mod(deg,2)
    error('BRAIDLAB:braid:alexpoly:baddegree',...
          'Bad degree: permutation is %s.',num2str(perm(b)))
  end
  p = p * laurpoly(1,deg/2);

 case 'sym'
  for i = 1:n-1, bu(i,i) = bu(i,i) - 1; end

  num = (-1)^(n-1)*det(bu);
  denom = sum(x.^[0:n-1]);

  % Long division of Laurent polynomials. They always divide each other exactly.
  p = simplify(num / denom);
  mono = simplify(p / subs(p,x,1/x));

  for m = [-1 1]
    try
      p2 = sym2poly(mono^m);
      break
    catch err
      if ~strcmpi(err.identifier,'symbolic:sym:sym2poly:errmsg2')
	rethrow
      end
    end
  end
  if any(p2(2:end))
    error('BRAIDLAB:braid:alexpoly:notmonomial',...
          'p(z) = p(1/z) cannot be enforced.')
  end
  deg = m*(length(p2)-1);
  if mod(deg,2)
    error('BRAIDLAB:braid:alexpoly:baddegree',...
          'Bad degree: permutation is %s.',num2str(perm(b)))
  end
  p = expand(simplify(p * x^(-deg/2)));

 otherwise
  error('BRAIDLAB:braid:alexpoly:unknowntype', ...
	'Unknown type.')
end
