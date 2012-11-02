function X = modroot(a,p)
% modroot: solve the quadratic residue sqrt, find x such that mod(x^2,p) == mod(a,p)
% usage: X = modroot(a,p)
%
% Given positive integer modulus p >= 2, solve
% for x such that mod(x^2,p) == mod(a,p). This is a modular
% square root problem, and requires factoring p into
% its prime factorization when p is composite. For
% prime values of p, Shanks-Tonelli is used.
%
% Requirements:
%   p >= 2
%
%   Also, many values of a will have no solution
%   for composite values of p.
%
%  http://en.wikipedia.org/wiki/Shanks-Tonelli_algorithm
%  http://planetmath.org/encyclopedia/ShanksTonelliAlgorithm.html
%
% Example: 
%  modroot(8,23)
%  ans =
%     10
% 
%  mod(10^2,23)
%  ans =
%      8
%
% Example: (no solution exists here, as 7 is not
%  a quadratic residue for 23.)
%
%  modroot(7,23)
%
%  Warning: No solution for the quadratic congruence exists
%  > In modroot at 45
%  ans =
%     []
%
% Example: (A quite large prime modulus)
%  p = vpi('10000000000037');
%  x = modroot(123,vpi('10000000000037'))
%
%  x =
%    9235841814625
%
% Verify the result:
%  mod(x.^2,p)
%  ans =
%    123
%
%  See also: mod, rem
%  
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/14/09

% test that N must be >= 2
if p<2
  error('p must be at least 2')
end

% reduce a modulo p
a = mod(a,p);

% simple cases
if (a == 0) || (a == 1)
  X = a;
  return
end

% for small p, just use brute force. the nice
% thing is, this will work for any small p,
% prime or composite, and working in doubles
% it will be fast.
pmax = 2^16;
if p <= pmax
  % convert to doubles, just in case
  p = double(p);
  a = mod(double(a),p);
  x = 1:(p/2);
  k = find(mod(x.^2,p) == a,1,'first');
  if isempty(k)
    warning('MODROOT:nosolution','No solution for the quadratic congruence exists')
    X = [];
    return
  end
  X = x(k);
  return
end

% p was too large, so do this the hard way
a = vpi(a);
p = vpi(p);

% Does an exact sqrt exist?
[X,exs] = sqrt(a);
if iszero(exs)
  % we can stop now
  return
end

% Is p prime or composite?
if isprime(p,2)
  % p is a prime
  
  % Does a solution exist at all? Check
  % the legendre symbol before we search.
  % we already know that a ~= 0, so L
  % cannot be zero. It will be +/- 1
  L = legendresymbol(a,p);
  if L == -1
    warning('MODROOT:nosolution','No solution for the quadratic congruence exists')
    X = [];
    return
  end
  
  % p is known to be larger than pmax, so
  % p == 2 is not an issue here.
  if mod(p,4) == 3
    % if p is a prime of the form 4k+3
    % a direct solution exists
    X = powermod(a,(p+1)/4,p);
    return
  else
    % p must be prime and of the form 4K+1
    % See either reference for Shanks-Tonelli
    
    % 1. factor out powers of 2 from p-1
    Q = p-1;
    S = 0;
    while iseven(Q)
      Q = Q/2;
      S = S + 1;
    end
    
    % 2. Choose a W such that (W/N) == -1,
    % where (W/N) is the legendre symbol.
    W = vpi(2);
    % This loop will terminate before long,
    % since half of the numbers below p will
    % have (W/p) == -1. Just start at some
    % point, and loop until we find one of
    % them.
    while legendresymbol(W,p) == 1
      W = W + 1;
    end

    % 3. compute V
    V = powermod(W,Q,p);
    
    % 4. compute an initial value for R
    R = powermod(a,(Q+1)/2,p);
    
    % 5. the multiplicative inverse of a
    % it must exist, since a > 0, and p is prime 
    ainv = minv(a,p);
    
    R2n = mod(R*R*ainv,p);
    i = 0;
    flag = true;
    while flag
      if isunit(R2n) && (i == 0)
        % this means we are done. return R
        % as the root of interest.
        flag = false;
        X = R;
      elseif isunit(R2n) || (i == (S-1))
        % since i ~= 0, restart with a new R
        R = mod(R*powermod(V,2^(S-i-1),p),p);
        i = 0;
        R2n = mod(R*R*ainv,p);
      else
        % increment i, we must be below S-1, and
        % square R2N
        i = i + 1;
        R2n = mod(R2n*R2n,p);
      end
    end
  end
else
  % p is composite, so we need to factor it
%   Flist = factor(p);
  error('I am sorry, but modroot is not yet implemented for large composite p')
  
  
  
  
  
  
end














