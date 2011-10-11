function [varargout] = intersec(obj)
%INTERSEC   Convert Dynnikov coding of loop to intersection numbers.
%   [MU,NU] = INTERSEC(L) returns the intersection numbers corresponding
%   to the loop L, as defined in figure 9 of ref. [2] below.
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

n = obj.n;
[a,b] = obj.ab;

% The number of intersections before/after the first and last punctures.
% See Hall & Yurttas (2009).
cumb = [0 cumsum(b,2)];
b0 = -max(abs(a) + max(b,0) + cumb(1:end-1));
bn1 = -b0 - sum(b);

% Extend the coordinates.
B = [b0 b bn1];
A = [0 a 0];

% Find nu, mu (intersection numbers).
nu(1) = -2*b0;
for i = 2:n-1
  nu(i) = nu(i-1) - 2*B(i-1 + 1);
end
for i = 1:2*n-4
  ic = ceil(i/2);
  mu(i) = (-1)^i * A(ic + 1);
  if B(ic + 1) >= 0
    mu(i) = mu(i) + nu(ic)/2;
  else
    mu(i) = mu(i) + nu(ic+1)/2;
  end
end

if nargout > 1
  varargout{1} = mu;
  varargout{2} = nu;
else
  varargout{1} = [mu,nu];
end
