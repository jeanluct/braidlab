function L = log2(N)
% vpi/log2: base 2 logarithm of the (positive) vpi number N
% usage: L = log2(N)
%
%
% arguments: (input)
%  N - a vpi scalar (positive) integer
%      N must be positive, or an error will
%      result.
%
%
% arguments: (output)
%  L - The base 2 logarithm (as a double)
%      of the vpi number N.
%
%
% Example:
%  log2(vpi(2)^193)
%  ans =
%         193
%
%
%  See also: vpi/log, vpi/log10, log, log10, power, sqrt
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/27/09


if isempty(N)
  % empty propagates
  L = [];
elseif numel(N) == 1
  % error check
  if N <= 0
    error('N must represent a positive integer')
  end
  
  % is N small enough to do it exactly?
  if N <= (2^53 - 1)
    L = log2(double(N));
    return
  end
  
  % shift the number to do it as a double
  Norder = order(N);
  excessdigits = max(0,(Norder - 18));
  if excessdigits>0
    N.digits(1:excessdigits) = [];
  end
  
  % compute the natural log by shifting the
  % log of the mantissa.
  L = log2(double(N)) + excessdigits/log10(2);
else
  % an array
  L = zeros(size(N));
  for i = 1:numel(N)
    L(i) = log2(N(i));
  end
end


