function factorlist = factor(INT,maxiter)
% vpi/factor: computes the factors of a large integer
% usage: factorlist = factor(INT,maxiter)
% 
% If the number is determined to be composite, and
% too large to be factored using simpler methods,
% then Pollard's rho method is used to find the
% factors. This may take a long time to run on
% nasty problems, but then factoring is a hard
% problem for very large numbers. factor is actually
% pretty efficient, able to factor most numbers in
% my tests with up to 20 digits or more in only a
% few seconds. The built-in factor is limited to
% only about 10 digit numbers, up to 2^32.
% 
% http://modular.fas.harvard.edu/edu/Fall2001/124/misc/arjen_lenstra_factoring.pdf
% 
% arguments: (input)
%  INT - a vpi scalar integer to be factored.
%        INT may also be numeric. Consistent
%        with factor, an error will be generated
%        if INT < 0.
%
%  maxiter - (OPTIONAL) Scalar numeric integer.
%        May be set to inf, if you are willing
%        to just let it run until termination.
%
%        DEFAULT: 1000
%
% arguments: (output)
%  factorlist - Normally a numeric (row) vector
%        of double precision integers. When one
%        or more of the factors is itself a vpi
%        number, then the entire array will
%        be a vpi row vector containing the
%        factors.
%
%        factorlist has the property that
%          prod(factorlist) == INT
%
%        If INT is a prime, then factorlist will
%        have only that single element in it, so
%        it will generally be a scalar VPI object.
%
%
% Example:
%  p = primes(1000000);
%
%  f0 = p([1 1 2 3 3 5 23 57 1111 5000 30000])
%  f0 =
%     2 2 3 5 5 11 83 269 8933 48611 350377
%
%  INT = prod(f0)
%  ans =
%     11210159485166916704100
%
%  f = factor(INT)
%  f =
%     2 2 3 5 5 11 83 269 8933 48611 350377
%
% See that the original list of factors was recovered,
% even though the number to be factored had 23 digits,
% and some of those factors were quite large themselves.
%
%
% Example:
%  INT = vpi('111111111111111111');
%  f = factor(INT)
%  f =
%     37  52579  333667
%
% Of course, the built-in factor fails miserably here.
%
%  factor(111111111111111111)
%    ??? Error using ==> factor at 25
%    The maximum value of n allowed is 2^32.
%
%
%  See also: isprime, rem, mod, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/24/09

if numel(INT) ~= 1
  error('VPI:FACTOR:nonscalarinput','INT must be a scalar to find its factors')
end

% ensure that INT is a vpi, and positive
INT = vpi(INT);
if INT.sign < 0
  error('VPI:FACTOR:negativeinput','INT must be non-negative')
elseif iszero(INT)
  factorlist = vpi(0);
  return
elseif ~isfinite(INT)
  error('VPI:FACTOR:finite','INT must be a finite number')
end

% use this number in a few places
two52 = vpi(2)^52;

% bring in a list of primes, if this is the
% first time calling factor. Otherwise, make it
% stick around. For those users who are worried
% about the long term memory allocated to
% primeslist, just comment out those three
% lines labeled with a %%% below. This will
% force matlab to reload the variable on each
% call to factor, at a cost of perhaps 1/4
% second each time factor is called.
persistent primeslist %#ok  %%%  
if isempty(primeslist) %%%
  try
    primeslist = getprimeslist;
  catch
    % in case of an older release, the
    % catch should fail, and create the
    % _primeslist_ file from scratch.
    % that file will then be saved on
    % the vpi search path, so this will
    % happen only once.
    createPrimesList
    primeslist = getprimeslist;
  end
end %%%

if comparemagnitudes(two52,INT)
  factorlist = vpi(bigfactor(double(INT),primeslist));
  return
end
% if we drop through here, then INT is > 2^52

% get an approximation to log10(INT)
log10app = order(INT) + log10(leadingdigit(INT,1));

% Can we eliminate any small prime factors?
factorlist = vpi([]);
[factorlist,INT] = extractsmallfactors(INT,factorlist,primeslist);

% we are done if INT has been reduced to 1
if isunit(INT)
  return
end

% check the size of INT once more. If it has
% been reduced in magnitude, then we might
% again be able to solve it by brute force.
if comparemagnitudes(two52,INT)
  factorlist = [factorlist,bigfactor(double(INT),primeslist)];
  return
end
% if we drop through here, then INT is > 2^52

% have we reduced INT in magnitude? if so, is this
% piece now a prime?
if isprime(INT,2)
  factorlist = [factorlist,INT];
  return
end

% just in case, check to see if what remains of
% INT is a perfect square. The test is fast, so
% take a shot.
[R,exs] = sqrt(INT);
if iszero(exs)
  Rfactors = factor(R);
  factorlist = sort([factorlist,Rfactors,Rfactors],[],'ascend');
  return
end

% default for maxiter?. I've put it here
% rather than in the very beginning of the
% code, because I will want to make it depend
% on the size of INT at this point, in case we
% have found some small factors.
if (nargin<2) || isempty(maxiter)
  maxiter = 1000;
end

% generate a random starting point,
%  2 <= x1 <= INT-1
X1 = 2 + randint(INT-3,1);

% The second series will run in parallel
% with the X1 series, but at twice the
% "speed".
X2 = mod(X1*X1+1,INT);

% Time to begin the iterative process.
iter = 1;
flag = true;
success = true;
% This waitbar will be infrequently updated,
% so the update cost is small.
H = waitbar(1-log10(INT)/log10app,'Factoring in progress');
while flag
  % Use GCD to get any common divisor
  div = gcd(abs(X2 - X1),INT);
  
  % was the GCD unity? if so, then no
  % divisor was found yet. Keep looking
  if ~isunit(div)
    % there was a non-unit gcd identified.
    % As well, we know that div must be
    % less than INT in magnitude, so it must
    % be a factor of INT.
    if comparemagnitudes(two52,div)
      % div was small enough that we can
      % chop it up using bigfactor
      factorlist = [factorlist,bigfactor(double(div),primeslist)]; %#ok
    else
      % div was too large in itself to factor.
      % is it prime?
      if isprime(div,2)
        % it looks like a prime number itself
        factorlist = [factorlist,div]; %#ok
      else
        % div is composite, but too big to
        % factor directly.
        factorlist = [factorlist,factor(div)]; %#ok
      end
    end
    
    % we can reduce INT by the GCD we just found.
    INT = INT/div;
    
    % update the waitbar
    L10 = order(INT) + log10(leadingdigit(INT,1));
    waitbar(1-L10/log10app,H)
    
    if isunit(INT)
      % we are done
      flag = false;
    else
      % INT has been reduced in magnitude,
      % but not to unity.
      if comparemagnitudes(two52,INT)
        % INT is now small enough that we can
        % chop it up.
        factorlist = [factorlist,bigfactor(double(INT),primeslist)]; %#ok
        INT = vpi(1);
        flag = false;
      elseif isprime(INT,2)
        % it looks like a prime number itself
        factorlist = [factorlist,INT]; %#ok
        INT = vpi(1);
        flag = false;
      end
        
      % INT is composite, but still too big to
      % factor directly. Just keep on working
      % on it.
    end
  end % if ~isunit(div)
  
  if flag
    % we still have some work to do on INT
    
    % step ahead in the parallel sequences
    % for X1 and X2.
    X1 = mod(X1*X1+1,INT);
    X2 = mod((X2*X2 + 1)^2 + 1,INT);
  end
  
  % increment the loop counter
  iter = iter + 1;
  if flag && (iter > maxiter)
    % terminate the iterations
    % stuff what remains into factorlist
    flag = false;
    success = false;
    factorlist = [factorlist,INT]; %#ok
  end
end % while flag
% kill the waitbar
delete(H)

% make one final, desperate, stab at the
% failed factorizations. Use pure brute
% force here. It frequently works though,
% even when the more sophisticated methods
% failed.
if ~success
  % Take the last element of factorlist and try
  % to factor it. Actually, this will be waiting
  % for us in the variable INT.
  
  % grab the top few digits of INT.
  td = leadingdigit(INT,17);
  % as a floating integer
  INTd = td*(10.^((length(td)-1):-1:0)');
  
  % take the list of all primes up to 1e8,
  % discarding those under 500 from that list
  % since we have already eliminated them from
  % any consideration.
  p = primeslist(96:end);
  
  % divide them all into INTd, rounding to
  % the nearest integer
  Q = round(INTd./p);
  
  % compute the absolute remainders
  R = abs(INTd - Q.*p);
  
  % discard those with a small remainder
  k = (R<200);
  p = p(k);
  R = R(k);
  
  if ~isempty(p)
    % sort them in increasing order
    [junk,tags] = sort(R);
    p = p(tags);
    
    % we have found some potential factors of INT
    factorlist(end) = [];
    
    % test each prime against INT
    i = 1;
    while (i<=length(p)) && ~isunit(INT)
      [Q,R] = quotient(INT,p(i));
      if iszero(R)
        % we have found a large prime factor of INT
        % stuff it into factorlist.
        factorlist = [factorlist,p(i)]; %#ok
        
        % this time, success merely means that we
        % have found at least one factor of INT.
        success = true;
        
        % finally, check Q. If it is prime, which
        % it very likely is, then just stuff it
        % into factorlist also.
        if isprime(Q,2)
          % Q was prime
          factorlist = [factorlist,Q]; %#ok
          INT = vpi(1);
        else
          % Q is still composite. Blast.
          % check Q against the other potential
          % factors we have identified.
          INT = Q;
        end
      end % if iszero(R)
      
      % increment i
      i = i+1;
    end% while (i<=length(p)) && ~isunit(INT)
    
    % Have we dropped through the end of this while
    % loop, having found at least one factor of
    % INT but there is still a known composite 
    % piece that remains unfactored?
    if ~isunit(INT)
      if ~success || maxiter<=50
        % absolutely nothing worked, and we have
        % probably tried this approach before.
        % just give up.
        factorlist = [factorlist,INT]; %#ok
      else
        % we did find a factor, so INT is smaller
        % than before. Try another pass at it with
        % factor before we give up. Let it go for
        % no more than 50 iterations or so.
        newmaxiter = min(50,floor(maxiter/2));
        factorlist = [factorlist,factor(INT,newmaxiter)]; %#ok
      end
    end
  end % if ~isempty(p)
end % if ~success

% when all is done, sort the factors in increasing order
factorlist = sort(factorlist,[],'ascend');


% =========================
%  end mainline
% =========================
%  begin subfunctions
% =========================

function flist = bigfactor(DINT,primeslist)
% a big cousin of factor, factoring numbers
% as large as 2^52. Uses brute force.

% just look at those primes that may be
% of interest. np is the number of primes that
% are less than an appropriate power of 2.
sqdint = sqrt(DINT);
if sqdint < 2
  k = 1;
elseif sqdint >= primeslist(end)
  k = length(primeslist);
else
  log2sqrt = log2(sqdint);
  np = [1 2 4 6 11 18 31 54 97 172 309 564 1028 ...
    1900 3512 6542 12251 23000 43390 82025 155611 ...
    295947 564163 1077871 2063689 3957809];
  
  % find the largest prime that is less than sqdint
  k = [np(max(1,floor(log2sqrt))) , np(min(26,ceil(1+log2sqrt)))];
  pk = primeslist(k);
  while diff(k) > 1
    kbar = floor(mean(k));
    pkbar = primeslist(kbar);
    
    if pkbar <= sqdint
      k(1) = kbar;
      pk(1) = pkbar;
    else
      k(2) = kbar;
      pk(2) = pkbar;
    end
  end
end
p = primeslist(1:k(1));

% completely factor DINT here by trial
% division
flist = [];
while DINT > 1
  k = find(rem(DINT,p) == 0);
  if ~isempty(k)
    p = p(k);
    flist = [flist,p]; %#ok
    DINT = DINT/prod(p);
  else
    flist = [flist,DINT]; %#ok
    DINT = 1;
  end
end
flist = sort(flist);

% =========================
function [factorlist,INT] = extractsmallfactors(INT,factorlist,primeslist)
% extracts the specified small factors from the number INT

% check for 2 as a factor
while ~isunit(INT) && (rem(INT.digits(1),2) == 0)
  INT = INT/2;
  factorlist = [factorlist,2]; %#ok
end
% check for 3 as a factor
while ~isunit(INT) && (rem(sum(INT.digits),3) == 0)
  INT = INT/3;
  factorlist = [factorlist,3]; %#ok
end
% check for 3 as a factor
while ~isunit(INT) && (rem(INT.digits(1),5) == 0)
  INT = INT/5;
  factorlist = [factorlist,5]; %#ok
end

plist = primeslist(4:95);

% just divide and check for a zero remainder
i = 1;
while ~isunit(INT) && (i <= length(plist))
  [Q,R] = quotient(INT,plist(i));
  if iszero(R)
    % plist(i) was a factor
    factorlist = [factorlist,plist(i)]; %#ok
    INT = Q;
  else
    i = i + 1;
  end
end


