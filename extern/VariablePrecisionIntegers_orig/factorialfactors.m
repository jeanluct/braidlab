function [facs,freps] = factorialfactors(n)
% factorialfactors: efficient computation of the prime factors of factorial(n)
% usage: [facs,freps] = factorialfactors(n)
%
% A number sieve is used to generate the list of factors
% 
% Arguments: (input)
%  n     - scalar, non-negative integer
%
% Arguments: (output)
%  facs  - row vector, a list of the prime factors of
%       factorial(n), sorted in increasing orsder.
%
%  freps - row vector, containing the number of occurrences
%       of each listed prime factor in the resulting
%       factorial.
%
%
% Example usage:
% % We could get the factors of factorial(100) using
% % factor(factorial(vpi(50))). But this is inefficient
% % and unnecessary.
%
% [facs,freps] = factorialfactors(50);
% [facs;freps]
% % ans =
% %    2  3  5  7 11 13 17 19 23 29 31 37 41 43 47
% %   47 22 12  8  4  3  2  2  2  1  1  1  1  1  1
%
% % Are these factors correct? The test is easy.
% 
% factorial(vpi(50))
% % ans =
% %    30414093201713378043612608166064768844377641568960512000000000000
%
% prod(vpi(facs).^freps)
% % ans =
% %    30414093201713378043612608166064768844377641568960512000000000000
% 
%
% % A second test for a bit larger argument
% tic
% [facs,freps] = factorialfactors(10000000);
% toc
%
% % Elapsed time is 2.277722 seconds.
%
% % Suppose we had tried to compute the actual
% % factorial itself, how many digits would it
% % have had?
% % (Answer: over 65 million decimal digits!)
%
% format long g
% sum(log10(ff).*fc)
%
% % ans =
% %           65657059.0800584
%
%
% See also: binomfactors, factorial, factor

% check that n is a scalar, and a nonegative integer.
if (nargin ~= 1)
  help factorialfactors
  return
elseif isempty(n)
  facs = [];
  freps = [];
  return
elseif (numel(n) ~= 1) || ~isnumeric(n) || (n<0) || (n ~= round(n))
  error('FACTORIALFACTORS:improperargument', ...
    'factorialfactors requires a scalar, nonnegative integer argument')
elseif (n==0) || (n==1)
  % factorial(0) = factorial(1) = 1, so there
  % are no prime factors.
  facs = [];
  freps = [];
  return
end

% we have already eliminated n == 0 or 1. So all
% other cases have at least one prime factor.
facs = primes(n);
np = length(facs);
freps = zeros(1,np);

% start the sieving operation
for i = 1:np
  p_i = facs(i);
  
  % how many times will p_i^k appear as a factor?
  ppower = p_i;
  while ppower <= n
    % remove factors of p_i from the product
    ppreps = floor(n/ppower);
    freps(i) = freps(i) + ppreps;
    
    % incrementally multiply ppower
    ppower = ppower*p_i;
  end
  
end




