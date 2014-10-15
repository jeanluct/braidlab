function [varargout] = intersec(obj)
%INTERSEC   Convert Dynnikov coding of loop to intersection numbers.
%   [MU,NU] = INTERSEC(L) returns the intersection numbers corresponding to
%   the loop L, as defined in figure 9 of ref. [2] below, reproduced in
%   figure 2(b) of the braidlab guide.
%
%   References:
%
%   [1] T. Hall & S. Yurttas, "On the topological entropy of families of
%   braids," Topology and its Applications 156 (2009), 1554-1564.
%
%   [2] J.-L. Thiffeault, "Braids of entangled particle trajectories," Chaos
%   20 (2010), 017516.
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.INTAXIS.

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

if ~isscalar(obj)
  n = obj(1).n;
  mu = zeros(length(obj),2*n-4);
  nu = zeros(length(obj),n-1);
  for k = 1:length(obj)
    [mu(k,:),nu(k,:)] = intersec(obj(k));
  end
else
  n = obj.n;
  [a,b] = obj.ab;

  % The number of intersections before/after the first and last punctures.
  % See Hall & Yurttas (2009).
  cumb = [zeros(size(b,1),1) cumsum(b,2)];
  b0 = -max(abs(a) + max(b,0) + cumb(:,1:end-1),[],2);
  bn1 = -b0 - sum(b,2);

  % Extend the coordinates.
  B = [b0 b bn1];
  A = [zeros(size(a,1),1) a zeros(size(a,1),1)];

  % Find nu, mu (intersection numbers).
  mu = zeros(size(a,1),2*n-4); nu = zeros(size(a,1),n-1);
  nu(:,1) = -2*b0;
  for i = 2:n-1
    nu(:,i) = nu(:,i-1) - 2*B(:,i-1 + 1);
  end
  for i = 1:2*n-4
    ic = ceil(i/2);
    mu(:,i) = (-1)^i * A(:,ic + 1);
    ii = (B(:,ic + 1) >= 0);
    mu(ii,i) = mu(ii,i) + nu(ii,ic)/2;
    mu(~ii,i) = mu(~ii,i) + nu(~ii,ic+1)/2;
  end
end

if nargout > 1
  varargout{1} = mu;
  varargout{2} = nu;
else
  varargout{1} = [mu,nu];
end
