function [tf,S] = mersenne(p)
% mersenne: identify whether 2^p-1 is a Mersenne prime, using the Lucas-Lehmer test
% usage: tr = mersenne(p)
%
% This is a simple test to apply, working fairly
% easily for Mersenne primes up to p at least a 
%
% http://mathworld.wolfram.com/Lucas-LehmerTest.html
% http://en.wikipedia.org/wiki/Mersenne_prime
%
% arguments: (input)
% p  - a (relatively small) prime
%
% arguments: (output)
% tf - boolean, true if 2^p-1 is prime
%
% Example:
%
%
%  See also: isprime
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/23/09

% ensure that p is a vpi
dp = double(p);

% Save the terms from the Lucas-Lehmer
% recurrence relation, just in case they
% are of interest.
S = cell(1,dp-1);

if ~isprime(dp)
  warning('p must be prime for 2^p-1 to be a mersenne prime')
  tf = false;
  return
end
p = vpi(p);

% compute the candidate Mersenne prime
mp = vpi(2)^p-1;

% S0 = 4
S = repmat(vpi(4),1,dp-1);

% and loop, from n = 1 to (p-2)
h = waitbar(0,'Stop bothering me. I''m thinking, can''t you see?');
for n = 1:(dp-2)
  waitbar(n/dp,h)
  S(n+1) = mod(S(n)*S(n) - 2,mp);
end
delete(h)

% mp is prime IFF this last term is zero
tf = (0 == S(dp-1));



