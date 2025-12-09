% Try to find reducing curves using inverse iteration.

%B = braid([1],3);
B = braid([-3  1 -4  2 -3 -1 -2  3 -2  4  3  4]);
lred = loop([0 -1 0 0 0 0]);
n = B.n;

Niter = 10;
mu = 1;
u = loop(ones(1,2*n-4));
%u = loop(rand(1,2*n-4));

for k = 1:Niter
  % Get linear action.
  [~,A] = B*u; A = full(A);
  up = (A - mu*eye(size(A))) \ u.coords.';
  u = loop(up/norm(up));
end

u
