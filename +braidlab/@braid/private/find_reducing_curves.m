function [linv,Q] = find_reducing_curves(b,l0)

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

import braidlab.*
global BRAIDLAB_debuglvl

badbraid = false;
if nargin < 1
  % The bad reducible braid.
  badbraid = true;
  b = braid([-3  1 -4  2 -3 -1 -2  3 -2  4  3  4]);
  lred = loop([0 -1 0 0 0 0 0 1]);
end

n = b.n;

if exist('BRAIDLAB_debuglvl','var')
  if BRAIDLAB_debuglvl >= 1
    tn = tntype(b);
    fprintf('braid is %s.\n',tn)
  end
end

% Use random initial loop if not specified.
if nargin < 2, l0 = loop(randi(5,1,2*n-2)-3); end

[M,period] = b.cyclemat('iter',l0);

Q = [];

for i = 1:period
  M{i} = full(M{i});

  % Check the badbraid case, where we know the reducing curve.
  if badbraid
    lred2 = b*lred;
    if ~all(lred2 == lred)
      fprintf('\nbadbraid: Somethings''s wrong... not a reducing curve.\n');
    end
    if any(M{i}*lred.coords' ~= lred.coords')
      fprintf('M{%d}*l ~= l',i);
      fprintf('\n\n')
      fprintf('     l = %s\n',num2str(lred.coords))
      fprintf('   b*l = %s\n',num2str(lred2.coords))
      fprintf('M{%d}*l = %s\n\n',i,num2str((M{i}*lred.coords')'))
      error('Invariant curve is not an eigenvector.')
    end
  end

  % Get rid of "boundary" Dynnikov coordinates, a_(n-1) and b_(n-1).
  % If we don't do this there is an extra reducing curve around the
  % first n punctures.
  ii = [(1:n-2) (1:n-2)+n-2+1];
  M{i} = M{i}(ii,ii);

  A = M{i} - eye(size(M{i}));
  [U,D,V] = snf(A);  % Smith form of A.

  % Check that everything is ok.
  if exist('BRAIDLAB_debuglvl','var')
    if BRAIDLAB_debuglvl >= 1
      checksnf(A,U,D,V);
    end
  end

  D = diag(D);

  Qit{i} = round(inv(V))';
  Qit{i} = Qit{i}(:,find(D == 0));

  if rank(Qit{i}) < size(Qit{i},2)
    error('Qit{%d} doesn''t have full rank.',i)
  end

  % Make sure first nonzero component is positive.
  for j = 1:size(Qit{i},2)
    inz = find(Qit{i}(:,j) ~= 0);
    if Qit{i}(inz(1),j) < 0
      Qit{i}(:,j) = -Qit{i}(:,j);
    end
  end

  % Take the intersection of the coordinates, since a loop must be
  % invariant for each iterate.
  if isempty(Q)
    Q = Qit{i};
  else
    Q = intersect(Q',Qit{i}','rows')';
  end

  % If the nullspace is empty, it cannot be reducible.
  if isempty(Q)
    Q = [];
    linv = [];
    return
  end
end

% If Q has rank one, easy to check if it's an invariant loop.
if size(Q,2) == 1

  linv = loop(Q);
  if b*linv == linv
    return
  end

  linv = loop(-Q);
  if b*linv == linv
    return
  end

  Q = [];
  linv = [];
  return
end

% Now cycle over linear combinations of the columns of Q.

mm = size(Q,2);

doplot = false;
if doplot
  close all
  figure
  for i = 1:mm
    subplot(mm,1,i)
    plot(loop(Q(:,i)))
  end
end

N = 3;  % Go from -N to N in each component.
%nwords = (2*N+1)^mm;

Z = -N*ones(mm,1); Z(end) = -N-1;

linv = [];

while 1
  incr = false;
  % Do not change the first generator (leave at 1).
  for w = mm:-1:1
    if Z(w) < N
      incr = true;
      % Increment the generator.
      Z(w) = Z(w)+1;
      break
    else
      % Otherwise reset generator at that position, and let the
      % loop move on to the next position.
      Z(w) = -N;
    end
  end

  % If nothing was changed, we're done.
  if ~incr, break; end

  l = loop(Q*Z);
  if b*l == l
    if ~all(l.coords == 0) && ~nested(l)
      linv = [linv ; l];
    end
  end
end

if exist('BRAIDLAB_debuglvl','var')
  if BRAIDLAB_debuglvl >= 1
    if ~strcmp(tn,'reducible') && ~isempty(linv)
      warning('Braid is not reducible, yet we found a reducing curve.')
    end
  end
end

if exist('BRAIDLAB_debuglvl','var')
  if BRAIDLAB_debuglvl >= 1
    if strcmp(tn,'reducible') && isempty(linv)
      % Example: < -3  1 -4  2 -3 -1 -2  3 -2  4  3  4 >  Why?
      warning('Braid is reducible, but we didn''t find a reducing curve.')
    end
  end
end
