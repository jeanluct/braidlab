function binomcoef = nchoosek(n,k)
% nchoosek: binomial coefficient, nchoosek
% usage: binomcoef = nchoosek(n,k)
%
% Computes the EXACT binomial coefficient for
% integer inputs. For many values of n and k,
% the built-in nchoosek will not yield the
% exactly correct number.
%
%
% arguments: (input)
%  n, k - Scalar, integer%
%
%         1 <= n
%         0 <= k <= n
%
% arguments: (output)
%  binomcoef = scalar vpi object, containing
%  the exact value of
%
%          factorial(n)
%  ----------------------------
%  factorial(k)*factorial(n-k))
%
%  
% Example:
%  nchoosek(1000,153)
%  ans = 
%     23406802950630897801212110091744080711686106480334726254279350482492
% 523248093523721420559973073007864828061641821634926337291968377863308317
% 337792702383711848133330236037192305827116000                           
%     
%
%  See also: factorial
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/25/09

% parameter checks
if (nargin~=2)
  error('You must supply both n and k for nCk and no other parameters')
elseif isempty(n) || (numel(n)~=1) || (n < 0) || (rem(n,1)~=0)
  error('n must be scalar, integer >= 1')
elseif isempty(k) || (numel(k)~=1) || (k < 0) || (rem(k,1)~=0) || (k > n)
  error('k must be scalar, integer >= 0 and <= n')
end

% convert to doubles for the processing
n = double(n);
k = double(k);

% check for some simple cases
if (k == 0) || (n==k)
  binomcoef = vpi(1);
  return
elseif (k == 1) || (k == (n-1))
  binomcoef = vpi(n);
  return
end

% which is larger, k or n-k?
if k > (n-k)
  k = n - k;
end

% use binomfactors to get the factors of the binomial
% coefficient. binomfactors is EXTREMELY fast, even
% for very large n.
[facs,count] = binomfactors(n,k);

% compute the binomial coefficient as a product
% of the prime factors as we just found.
binomcoef = prod(vpi(facs).^count);





