function D = halftwist(n)
%HALFTWIST   Return the generator representation of the positive half-twist.
%   D = HALFTWIST(N) returns the word D in Artin generators representing
%   the positive half-twist (Delta) for teh braid group of order N.

D = [];
for i = 1:n-1
  D = [D n-1:-1:i];
end
