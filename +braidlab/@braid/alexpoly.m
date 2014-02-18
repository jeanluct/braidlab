function p = alexpoly(b,x,opt)
%ALEXPOLY   Alexander polynomial of a braid.
%   P = ALEXPOLY(B) returns the Alexander polynomial (or Alexander-Conway
%   polynomial) of the closure of the braid B.
%
%   The Alexander polynomial is a Laurent polynomial (it has negative as
%   well as positive powers), which is represented by default using the
%   Matlab wavelet toolbox class 'laurpoly'.  If the wavelet toolbox is
%   unavailable, the symbolic toolbox is used.
%
%   P = ALEXPOLY(B,X) uses the object X for the polynomial variable.
%   Supported objects are X=laurpoly(1,1) (from the Matlab wavelet toolbox,
%   the default) and X=sym('x') (from the Matlab symbolic toolbox). X can
%   also be a numeric type (a real or complex number), but in that case the
%   'centered' option below is unavailable.
%
%   P = ALEXPOLY(B,X,'centered') or ALEXPOLY(B,'centered') centers the
%   polynomial so that P(X) = (+/-)P(1/X).  (The + sign always applies if
%   the closure of the braid is a knot, rather than a link.)  This may fail
%   when using the laurpoly class, since polynomials with fractional powers
%   cannot be represented by a laurpoly object.  This option is unavailable
%   when X is a numeric type,
%
%   Example: the trefoil knot 3_1 is the closure of sigma_1^3.  Its
%   Alexander polynomial is
%
%   >> ALEXPOLY(braid('3_1'))
%
%   ans = + z^(+2) - z^(+1) + 1
%
%   This can be centered to make the Laurent polynomial palindromic:
%
%   >> ALEXPOLY(braid('3_1'),'centered')
%
%   ans(z) = + z^(+1) - 1 + z^(-1)
%
%   To use the symbolic toolbox instead (much slower), specify the
%   polynomial variable as a second argument:
%
%   >> ALEXPOLY(braid('3_1'),sym('x'))
%
%   ans = x^2 - x + 1
%
%   The braid [1 1], which corresponds to the Hopf link, cannot be centered
%   using the laurpoly class, since this requires fractional exponents:
%
%   >> ALEXPOLY(braid([1 1]),'centered')
%
%   Error using braidlab.braid/alexpoly
%   Polynomial with fractional powers.  Remove 'centered' option or use
%   the symbolic toolbox.
%
%   >> ALEXPOLY(braid([1 1]))
%
%   ans(z) = - z^(+1) + 1
%
%   >> ALEXPOLY(braid([1 1]),sym('x'),'centered')
%
%   ans = 1/x^(1/2) - x^(1/2)
%
%   References:
%
%   E. Weisstein, "Alexander Polynomial." From MathWorld -- A Wolfram Web
%   Resource. http://mathworld.wolfram.com/AlexanderPolynomial.html
%
%   D. Rolfsen, "Knots and Links," AMS Chelsea (2003).
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

center = false;
stringopt = false;

if nargin == 2 && ischar(x)
  opt = x;
  x = [];
  stringopt = true;
end

if nargin == 3, stringopt = true; end

if nargin < 2 || isempty(x)
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

if stringopt
  if any(strcmpi(opt,{'center','centre','centered','centred'}))
    if ~isnumeric(x)
      center = true;
    else
      error('BRAIDLAB:braid:alexpoly:cantcenter', ...
            'Can''t center polynomial for numeric types.')
    end
  elseif any(strcmpi(opt,{'center','centre','centered','centred'}))
    center = true;
  elseif any(strcmpi(opt, ...
             {'nocenter','uncentered','uncentred','uncenter','uncentre'}))
    center = false;
  else
    error('BRAIDLAB:braid:alexpoly:badarg', ...
          'Unknown option %s.')
  end
end

errnotmono = {'BRAIDLAB:braid:alexpoly:notmonomial', ...
              'p(z) = p(1/z) cannot be enforced.'};
errfracpow = {'BRAIDLAB:braid:alexpoly:fracpoly', ...
              ['Polynomial with fractional powers.  Remove ' ...
               '''centered'' option or use the symbolic toolbox.']};

% Compute reduced Burau representation of the braid.
bu = burau(b,x);
n = b.n;

if strcmp(class(x),'laurpoly')
  for i = 1:n-1, bu{i,i} = bu{i,i} - 1; end

  num = (-1)^(n-1)*det(bu);
  denom = laurpoly(ones(1,n),n-1);

  % Long division of Laurent polynomials. They always divide each other exactly.
  p = mldivide(num,denom);

  if center
    % Balance polynomial so p(z) = p(1/z).
    pp = mldivide(reflect(p),p);
    if ~ismonomial(pp)
      error(errnotmono{:})
    end
    deg = get(pp,'maxDEG');
    if mod(deg,2)
      error(errfracpow{:})
    end
    p = p * laurpoly(1,deg/2);
  end

elseif strcmp(class(x),'sym') || isnumeric(x)
  for i = 1:n-1, bu(i,i) = bu(i,i) - 1; end

  num = (-1)^(n-1)*det(bu);
  denom = sum(x.^[0:n-1]);

  % The polynomials always divide each other exactly.
  p = num / denom;
  if ~isnumeric(x), p = simplify(p); end

  if center
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
      error(errnotmono{:})
    end
    deg = m*(length(p2)-1);
    p = p * x^(-deg/2);
  end
  % simplify/expand help put it in polynomial form.  Sometimes fails.
  if ~isnumeric(x), p = expand(simplify(expand(simplify(p)))); end

else
  error('BRAIDLAB:braid:alexpoly:unknowntype', ...
        'Unknown type.')
end
