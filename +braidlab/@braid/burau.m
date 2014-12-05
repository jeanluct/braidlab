function m = burau(b,t)
%BURAU   The Burau matrix representation of a braid.
%   M = BURAU(B,T) returns the reduced Burau matrix representation for the
%   braid B, with Burau parameter T.  Here T is a complex number with |T|=1
%   (default T=-1).
%
%   M = BURAU(B,T), where T is a Laurent polynomial class object, returns
%   the Burau representation as a cell array with Laurent polynomial
%   entries.  With the wavelet toolbox, use BURAU(B,laurpoly(1,1)).  With
%   the symbolic toolbox, use BURAU(B,sym('t')).  Note that the symbolic
%   toolbox is much slower.
%
%   M = BURAU(B,'Abs') returns the matrix of the "absolute value" monoid,
%   where every nonzero entry of the Burau matrices of the standard braid
%   generators are set to one, before multiplying them together.  The
%   spectral radius of this matrix is an upper bound on the braid's
%   dilatation.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY, BRAID.ALEXPOLY, LAURPOLY, LAURMAT.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

% Multiplication of numeric type by t must be defined.
sc = -1;  % -1 is Birman's convention, +1 is Kassel-Turaev.
typ = str2func(class(t));

% Make diagonal matrix.
m(1:n-1,1:n-1) = typ(0);
for i = 1:n-1, m(i,i) = typ(1); end

for sig = b.word(end:-1:1)
  i = abs(sig);
  if sig > 0
    for q = 1:n-1
      if i-1 > 0, m(i-1,q) = m(i-1,q) + afun(sc*t)*m(i,q); end
      if i+1 < n, m(i+1,q) = afun(sc)*m(i,q) + m(i+1,q); end
      m(i,q) = afun(-t)*m(i,q);
    end
  else
    for q = 1:n-1
      if i-1 > 0, m(i-1,q) = m(i-1,q) + afun(sc)*m(i,q); end
      if i+1 < n, m(i+1,q) = afun(sc/t)*m(i,q) + m(i+1,q); end
      m(i,q) = afun(-1/t)*m(i,q);
    end
  end
  if isa(t,'sym'), m = simplify(m); end
end
if isa(t,'laurpoly')
  m = laurmat(num2cell(m));
end
