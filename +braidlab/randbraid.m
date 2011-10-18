function b = randbraid(n,k)
%RANDBRAID   Generate a random braid.
%   B = RANDBRAID(N,K) returns a random braid of N strings with K crossings
%   (generators).  The K generators are chosen uniformly in [-(N-1):-1 1:N-1].
%
%   See also BRAID.

b = braidlab.braid((-1).^randi(2,1,k) .* randi(n-1,1,k),n);
