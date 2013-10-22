function L = log10(N)
% vpi/log10: logarithm to the base 10 of the (positive) vpi number N
% usage: L = log10(N)
%
%
% arguments: (input)
%  N - a vpi scalar (positive) integer
%      N must be positive, or an error will
%      result.
%
%
% arguments: (output)
%  L - The base 10 logarithm (as a double)
%      of the vpi number N.
%
%
% Example:
%  log10(vpi(10)^99)
%  ans =
%         99
%
%
%  See also: log, log2, power, sqrt
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
    L = log10(double(N));
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
  L = log10(double(N)) + excessdigits;
else
  % an array
  L = zeros(size(N));
  for i = 1:numel(N)
    L(i) = log10(N(i));
  end
end


