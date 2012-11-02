function [Fn,Ln] = modfibonacci(n,modulus)
% fibonacci: compute the n'th Fibonacci number and the n'th Lucas number, all modulo a given value
% usage: [Fn,Ln] = modfibonacci(n,modulus)
%
% Compute the nth Fibonacci number as well as the nth Lucas
% Lucas number.
%
% Both the Fibonacci numbers and the Lucas numbers
% are defined by the same basic recursion:
%
%  F(n) = F(n-1) + F(n-2)
%  L(n) = L(n-1) + L(n-2)
%
% The difference is the starting point. The Fibonacci
% numbers start with F(1) = F(2) = 1, whereas the Lucas
% sequence starts with L(1) = 1, and L(2) = 3. The first
% few members of these sequences are:
%
%  Fibonacci: [1 1 2 3 5 8 13 21 ... ]
%  Lucas:     [1 3 4 7 11 18 29 ... ]
%
% These sequences are also defined for n = 0 and for
% negative values of n.
%
% For efficiency, fibonacci uses a variety of tricks to
% maximize speed. While computation of fibonacci numbers
% is commonly done recursively, fibonacci does so using a
% direct iterative scheme given the binary representation
% of n. In addition, several Fibonacci and Lucas number
% identities are employed to maximize throughput.
%
% The methods employed by fibonacci will be O(log2(n)) in time.
%
%
% Arguments: (input)
%  n - any non-negative integer, vpi or numeric.
%
%      When n is a vector or array, fibonacci will
%      generate the modulus for each of the indicated
%      Fibonacci and Lucas numbers.
%
%  modulus - scalar integer value, used to compute mod(n,modulus)
%
% Arguments: (output)
%  Fn, Ln - scalar vpi number, containing the nth
%      Fibonacci number and nth Lucas numbers in
%      their respective sequences.
%
% Example:
% % Find the 50 trailing digits of fibonacci(17^17) (an immensely huge number)
% tic,[Fn,Ln] = modfibonacci(vpi(17)^17,vpi(10)^50),toc
%
% Elapsed time is 0.853440 seconds.
%
% Fn =
%    95580314894188580883157635516996057690106717033385
% Ln =
%    97021797404316989134330675487636762456133231992923
%
%  See also: fibonacci
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 10/13/2010

if (nargin ~= 2)
  error('fibonacci accepts only 2 arguments')
elseif any(n(:)~=round(n(:)))
  error('n must be an integer')
end

% The first 15 Fibonacci and Lucas numbers to
% start things off efficiently.
Fseq = [0 1 1 2 3  5  8 13 21 34  55  89 144 233 377  610];
Lseq = [2 1 3 4 7 11 18 29 47 76 123 199 322 521 843 1364];

% intialize Fn and Ln to the proper size,
% in case n is a vector or array
Fn = repmat(vpi(0),size(n));
Ln = Fn;

% much faster if n is not a vpi but a double.
% also, we don't need to worry about n being
% larger than 2^53, as this would have a vast
% number of digits.
n = double(n(:));

% catch any zeros in n first.
k = (n(:) == 0);
% Fn(k) is already zero
if any(k)
  Ln(k) = vpi(2);
end

% Negative values for n will be inconvenient
% in a loop, so make them all positive. deal
% with any signs later.
nsign = 2*(n>=0) - 1;
if any(n<0)
  neven = iseven(n);
  n = abs(n);
end


for in = 1:numel(n)
  ni = n(in);
  
  % For each value of n, compute it individually.
  % Uses an efficient iterative (recursive, but not
  % really so) scheme.
  
  % get the binary representation of n. Thus
  % nbin is a character vector, of length
  % ceil(log2(n)).
  nbin = dec2bin(n);
  
  % get the 4 highest order bits from nbin
  k = min(numel(nbin),4);
  
  % start the sequence from the top
  % few bits of n.
  nhigh = bin2dec(nbin(1:k));
  
  Fn = mod(vpi(Fseq(nhigh+1)),modulus);
  Ln = mod(vpi(Lseq(nhigh+1)),modulus);
  
  % We need to loop forwards. Essentially, we started
  % with the highest order bit(s) of the binary representation
  % for n. Look at each successively lower order bit.
  % If the next bit is 0, then we are essentially doubling
  % the index at this step. If the next bit is odd, then
  % we are moving to 2*n+1.
  for k = 5:numel(nbin)
    bit = (nbin(k) == '1');
    if bit
      % the next bit was odd. Use
      % a 2*n+1 rule to step up.
      F2n = Fn.*Ln;
      % we want to do this...
      %   L2n = (5 .*Fn.*Fn + Ln.*Ln)./2;
      % Instead use the identity that
      %   5F(n)^2 + L(n)^2 = 2*L(n)^2 + 4*(-1)^(n+1)
      % to make that expression more efficiently
      % computed. See that the form used below
      % has only a single multiplication between a
      % pair of large integers, whereas the prior
      % form for L2n would have had several multiples
      % as well as a divide.
      L2n = Ln.*Ln + 2*(-1)^(nhigh+1);
      
      Fn = L2n + F2n;
      if ~iseven(Fn)
        Fn = Fn + modulus;
      end
      Fn = mod(Fn/2,modulus);
      
      Ln = 5 .*F2n + L2n;
      if ~iseven(Ln)
        Ln = Ln + modulus;
      end
      Ln = mod(Ln/2,modulus);
      
    else
      % the next bit was even. Use the 2*n
      % rule to step up.
      F2n = mod(Fn.*Ln,modulus);
      Ln = mod(Ln.*Ln + 2*(-1)^(nhigh+1),modulus);
      Fn = F2n;
    end
    
    % update the top bits of n
    nhigh = 2*nhigh + bit;
  end % for k = 5:numel(nbin)
  
end % if numel(n) > 1

% if n was negative, then we may need to apply a
% sign change to Fn and Ln.
if any(nsign < 0)
  k = neven & (nsign < 0);
  Fn(k) = -Fn(k);

  k = (~neven) & (nsign < 0);
  Ln(k) = -Ln(k);
end

% ==================================
% End mainline, begin subfunctions.
% ==================================

function result = iseven(n)
% tests if a scalar value is an even integer, works
% for either numeric or vpi inputs
if isnumeric(n)
  result = (mod(n,2) == 0);
elseif isa(n,'vpi')
  % must have been a vpi
  result = (mod(trailingdigit(n,1),2) == 0);
else
  error('n must be either numeric or vpi')
end


