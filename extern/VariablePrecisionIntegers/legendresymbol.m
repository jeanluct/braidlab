function S = legendresymbol(a,p)
% legendresymbol: computes the legendre symbol (a/p) for prime p
% usage: S = legendresymbol(a,p)
%
% arguments: (input)
%  a - scalar integer or vpi number
%  p - positive scalar integer or vpi number
%
% arguments: 
%  S - a scalar (double) integer
%
%      =  0, if mod(a,p) = 0
%      = +1, if there exists x such that mod(x^2,p) == a
%      = -1, if there does not exist an x such that mod(x^2,p) == a
%
%
% Example:
% Pick a small prime p, so that we can easily
% list all possible quadratic residues.
%  
%  p = 17;
%  quadraticresidues(p)
% ans =
%      0  1  2  4  8  9 13 15 16
%
% For if a is an integer multiple of p, then
% the legendre symbol is zero.
%
%  legendresymbol(34,p)
% ans =
%      0
%
% 4 is indeed a quadratic residue
%  legendresymbol(4,p)
% ans =
%      1
% 
% 11 is not a quadratic residue
%  legendresymbol(11,p)
% ans =
%     -1
%
%
% Example:
% Pick a random large prime p. (Yes, it is a prime.)
%  p = vpi('1198112137');
%
% Pick some other random number x.
%  x = vpi(4652356);
%
%  x^2
% ans =
%    21644416350736
%
%  a = mod(x^2,p)
% a =
%    520595831
%
% See that the legendre symbol (a/p) is 1, indicating
% that there exists an (unspecified) integer x such
% that mod(x^2,p) == a. Of course, we know this to
% be true, since we have constructed a from a known x.
%
%  legendresymbol(a,p)
% ans =
%      1
%
% However, for this value of a, there does not exist
% an x such that mod(x^2,p) == a+1.
% 
%  legendresymbol(a+1,p)
% ans =
%     -1
%
%
% See also: quadraticresidues, powermod, mod, rem, power, factor, isprime
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 2/9/09

% we need vpi numbers here
a = vpi(a);
p = vpi(p);

if p <= 1
  error('p must be prime and at least 2')
end

% if p is not prime, then the Jacobi symbol applies here
if ~isprime(p,2)
  % p was not a prime number
  error('p must be prime. Use jacobisymbol for composite p')
end

% there are a few special cases to look at.
if p == 2
  % do we have p == 2?
  % if a is even, then the legendre symbol is zero.
  % if a is odd, then a is a quadratic residue.
  if iseven(a)
    S = 0;
  else
    S = 1;
  end
elseif iszero(mod(a,p))
  % reduce a modulo p to check if the result is zero
  % if the mod is zero, then so is the Legendre symbol.
  S = 0;
else
  % p must now be an odd prime.
  % simplest is just to use little Fermat, which
  % will generate either +1 or p-1 (mod p)
  S = powermod(a,(p-1)/2,p);
  if S == 1
    % S was 1, therefore a was a quadratic residue mod p
    S = 1;
  else
    % S must be p-1, which is equivalent to -1 (mod p)
    S = -1;
  end
end



