function P = catdigits(N,M)
% catdigits: concatenates the digits of N and M into an aggregate number
% usage: P = catdigits(N,M)
%
% arguments:
%  N,M - any numeric or vpi integer, scalar or arrays
%        Scalar N or M will be expanded to match their
%        counterparts.
%
%  P   - a vpi array of concatenated numbers, of the
%        same size and shape as N and M
%
% Example:
%  catdigits(23,0:5)
% ans =
%   230   231   232   233   234   235
%
%  catdigits(0:5,23)
% ans =
%    23   123   223   323   423   523
%
%  catdigits(eye(3),magic(3))
% ans =
%    18    1    6
%     3   15    7
%     4    9   12
%
%  See also: digits
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 5/8/09


if nargin ~= 2
  error('Exactly 2 arguments required')
end

nN = numel(N);
nM = numel(M);

if (nN == 0) || ((nN == 1) && (N == 0))
  P = M;
elseif (nM == 0)
  P = N;
elseif ((nN*nM) == 1)
  % both are scalars
  N = vpi(N);
  M = vpi(M);
  
  P = digits(N,[digits(N),digits(M)]);
elseif (nN == 1)
  % N is a scalar, do scalar expansion
  P = vpi(M);
  for i = 1:nM
    P(i) = catdigits(N,M(i));
  end
elseif (nM == 1)
  % M is a scalar, do scalar expansion
  P = vpi(N);
  for i = 1:nN
    P(i) = catdigits(N(i),M);
  end
elseif all(size(N) == size(M))
  % two arrays of the same size and shape
  P = vpi(N);
  for i = 1:nN
    P(i) = catdigits(N(i),M(i));
  end
else
  % N and M are incompatible
  error('N and M are incompatible in shape or size for digit concatenation')
end



