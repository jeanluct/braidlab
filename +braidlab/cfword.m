function w = cfword(cf)
%CFWORD   Word representation of a canonical form.
%   W = CFWORD(CF) returns the word W in Artin generators representing
%   the left or right canonical form CF.
%
%   See also CANFORM, CFLENGTH, CFEQUAL.

n = cf.n;
D = braidlab.halftwist(n);

w = cell2mat(cf.factors);

if cf.delta < 0
  k = -cf.delta;
  D = -D(end:-1:1);
else
  k = cf.delta;
end

switch lower(cf.type)
 case 'lcf'
  w = [repmat(D,[1 k]) w];
 case 'rcf'
  w = [w repmat(D,[1 k])];
 otherwise
end
