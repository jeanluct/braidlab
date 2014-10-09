% Test zeros function for pre-allocating loops.  See issue #53.

N = 2000;
n = 10;

% The bad way: no pre-allocation.
% Completely awful running time.
if N <= 2000
  tic
  l1 = [];
  for i = 1:N
    l1 = [l1; loop(n)];
  end
  toc
end

% The good way: pre-allocation.
tic
l2 = loop(zeros(N,2*n-2));
for i = 1:N
  l2(i) = loop(n);
end
toc

% The old way: pre-allocation with by creating the last element.
% This works as well as the other two ways.
tic
l4 = loop(n); % Have to do this first.  Is this a bug?
l4(N) = loop(n);
for i = 1:N
  l4(i) = loop(n);
end
toc
