% Test zeros function for pre-allocating loops.  See issue #53.

N = 2000;
n = 10;

% Very bad: no pre-allocation.
% Completely awful running time.
if N <= 2000
  tic
  l1 = [];
  for i = 1:N
    l1 = [l1; loop(n)];
  end
  toc
end

% Good: pre-allocation directly on the coordinates.
tic
l2 = loop(zeros(N,2*n-2));
for i = 1:N
  l2(i) = loop(n);
end
toc

% Good: pre-allocation using default loop.
tic
l3 = loop(n,N);
for i = 1:N
  l3(i) = loop(n);
end
toc

% Good: pre-allocation using default loop.  No boundary puncture.
tic
l4 = loop(n,N,'nobasepoint');
for i = 1:N
  l4(i) = loop(n,'nobasepoint');
end
toc

% Good: pre-allocation with by creating the last element.
tic
l5(N) = loop(n);
for i = 1:N
  l5(i) = loop(n);
end
toc
