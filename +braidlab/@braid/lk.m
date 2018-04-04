function m = lk(b,t,q)
%LK   The Lawrence-Krammer matrix representation of a braid.
%   M = LK(B,T,Q) returns the matrix M for the Lawrence-Krammer
%   representation of the braid B, with module parametesr T and Q.  Here T
%   and Q are complex numbers with |T|=|Q|=1 (default T=1, Q=-1).
%
%   M = LK(B,sym('t'),sym('q')) uses monomials from the symbolic toolbox.
%
%   The matrix M has dimension N(N-1)/2, where N is the number of strings
%   of B.  This method can be very slow when using the symbolic toolbox,
%   even for moderate N.
%
%   Unlike the Burau representation, the Lawrence-Krammer representation is
%   faithful for all N.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.BURAU.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2018  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <marko@clarkson.edu>
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

% Default values (double).
if nargin < 3, q = -1; end
if nargin < 2, t = 1; end

n = b.n;
N = n*(n-1)/2;   % matrix dimension

if n == 2
  m(1,1) = (-q^2*t)^writhe(b);
  return
end

% The type of parameters t and q.
typ = str2func(class(t));
% If q is symbolic but not t, typ is symbolic.
if strcmpi(class(q),'sym') && ~strcmpi(class(t),'sym')
  typ = str2func('sym');
end

% Fill matrices for generators.
[sig,isig] = fillgens(n,t,q,typ);

%check_relations(sig)
%check_relations(isig)

% Make diagonal matrix.
m = typ(eye(N));

% Multiply matrices together according to the braid word.
for gen = b.word(end:-1:1)
  i = abs(gen);
  if gen > 0
    m = m*squeeze(sig(i,:,:));
  else
    m = m*squeeze(isig(i,:,:));
  end
  if isa(m(1,1),'sym'), m = simplify(m); end
end

%========================================================================
function [sig,isig] = fillgens(n,t,q,typ)

% Make this persistent for each n?  Difficult to do since t and q can change.

v = zeros(n-1,n);
N = n*(n-1)/2;

sig = typ(zeros(n-1,N,N));
isig = typ(zeros(n-1,N,N));

% Make an index of the basis of the module.
idx = 1;
for j = 1:n-1
  for k = j+1:n
    v(j,k) = idx;
    idx = idx + 1;
  end
end

% Fill matrices with the Lawrence-Krammer representation.  Not the prettiest
% or fastest code, but it is easy to check that it works fine with the
% check_relations function below.
for i = 1:n-1
  for j1 = 1:n-1
    for k1 = j1+1:n
      for j2 = 1:n-1
        for k2 = j2+1:n
          el = 0;
          if (j1==j2 && k1==k2 && i~=j1-1 && i~=j1 && i~=k1 && i~=k1-1)
            el = 1;
          elseif (i==j2 && k1==k2 && i==j1-1)
            el = q;
          elseif (j2==i && k2==j1 && i==j1-1)
            el = q*(q-1);
          elseif (j1==j2 && k1==k2 && i==j1-1)
            el = 1-q;
          elseif (k1==k2 && i==j1 && j1~=k1-1 && j2==j1+1)
            el = 1;
          elseif (i==k2 && j1==j2 && i==k1-1 && j1~=k1-1)
            el = q;
          elseif (i==k1-1 && j1~=k1-1 && j1==j2 && k1==k2)
            el = 1-q;
          elseif (i==k1-1 && j1~=k1-1 && i==j2 && k1==k2)
            el = -q*(q-1)*t;
          elseif (j1==j2 && i==k1 && k2==k1+1)
            el = 1;
          elseif (j1==j2 && k1==k2 && i==j1 && j1==k1-1)
            el = -t*q*q;
          end
          sig(i,v(j1,k1),v(j2,k2)) = el;
        end
      end
    end
  end
end

for i = 1:n-1
  isig(i,:,:) = inv(squeeze(sig(i,:,:)));
end

%========================================================================
function ok = check_relations(sig) %#ok<DEFNU>

% Verify that the braid relations are satisfied.

n = size(sig,1)+1;

fprintf('Commutation relations:\n')
for i = 1:n-2
  for j = i+2:n-1
    fprintf('%2g %2g  ',i,j)
    ij = squeeze(sig(i,:,:))*squeeze(sig(j,:,:));
    ji = squeeze(sig(j,:,:))*squeeze(sig(i,:,:));
    d = simplify(ij - ji);
    ok = all(d(:) == 0);
    if ~ok, return; end
    fprintf('ok\n')
  end
end

fprintf('Braid relations:\n')
for i = 1:n-2
  fprintf('%2g     ',i)
  iji = squeeze(sig(i,:,:))*squeeze(sig(i+1,:,:))*squeeze(sig(i,:,:));
  jij = squeeze(sig(i+1,:,:))*squeeze(sig(i,:,:))*squeeze(sig(i+1,:,:));
  d = simplify(iji - jij);
  ok = all(d(:) == 0);
  if ~ok, return; end
  fprintf('ok\n')
end
