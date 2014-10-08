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

% The good way (1): pre-allocation.
tic
l2 = zeros(N,1,'braidlab.loop');
for i = 1:N
  l2(i) = loop(n);
end
toc

% The good way (2): pre-allocation with 'like' size.
% I thought this would be better, but same speed as (1).
tic
l = loop(n);
l3 = zeros(N,1,'like',l);
for i = 1:N
  l3(i) = loop(n);
end
toc

% The old way: pre-allocation with by creating the last element.
% This works as well as the other two ways.
tic
l4(N) = loop(n);
for i = 1:N
  l4(i) = loop(n);
end
toc
