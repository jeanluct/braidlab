function [facs,count,lognck] = binomfactors(n,k)
% binomfactors: list all factors of the binomial coefficient nchoosek(n,k)
% usage: [facs,count,lognck] = binomfactors(n,k)
%
% binomfactors uses sieving schemes to find all factors
% of the indicated binomial coefficient. This scheme
% is extremely efficient, allowing the user to find
% the factors of HUGE binomial coefficients, with 
% thousands of digits.
%
% For exceedingly large n, the computation of
% nchoosek(n,k) itself will be a highly intensive
% computation. However, computation of the factors
% and the multiplicites thereof, is FAR easier. 
%
% in the event that we could compute the 
%
% arguments: (input)
%  n,k - numeric scalar values, that would be
%      arguments to the function nchoosek.
%
% arguments: (output)
%  facs - a row vector, listing all the factors
%      of nchoosek(n,k) as numeric (double) values.
%
%  count - the number of times each of the factors
%      facs appears in the value of nchoosek.
% 
%  lognck - log(nchoosek(n,k)), computed from the
%      factors and counts. natural log is used here.
%
%
% Example:
%  tic
%  [facs,count,lognck] = binomfactors(1000000,500000);
%  toc
%
% Elapsed time is 4.301428 seconds.
%
% numel(facs)
% ans =
%       53481
%
% lognck
% lognck =
%       693140.047013071
%
% See that the actual binomial coefficient would
% have had lognck/log(10) = 301027 digits in that
% result!
%
%
%  See also: nchoosek, factor, isprime, vpi
%
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 4/23/09

% just in case they came in as vpi numbers,
% or as some other class of integers.
n = double(n);
k = double(k);

if (k == 0) || (k == n)
  % in either of these events, nchoosek(n,k) == 1
  % The number 1 has no prime factors.
  facs = [];
  count = [];
  lognck = 0;
  return
end

% start point for the numerator terms
nst = n-k+1;

% when k is greater than n/2, we can swap
% k and nst
if nst < k
  k = n - k;
  nst = n-k+1;
end

num = nst:n;
den = 1:k;

% list of primes that will be factors of den
pden = primes(k);

% each denominator prime will divide into SOME
% of the numerator terms. which ones?
fc = [pden',zeros(numel(pden),1)];
for ip = 1:numel(pden)
  p = pden(ip);
  
  % for each prime in pden, we must kill it
  % off in the denominator terms, and corresponding
  % factors of p in the numerator.
  p2 = p;
  while p2 <= k
    indd = p2:p2:k;
    L = mod(nst,p2);
    indn = (mod(p2 - L,p2)+1):p2:k;
    
    den(indd) = den(indd)/p;
    num(indn) = num(indn)/p;
    if numel(indd) < numel(indn)
      % we divided out too many factors of p
      % from the numerator terms
      fc(ip,2) = fc(ip,2) + numel(indn) - numel(indd);
    end
    
    % look for powers of p, until that power exceeds k
    p2 = p2*p;
  end
  
  % We have killed off any powers of p in the denominator
  % terms. However, there may still be one or more powers
  % of these primes that remain in the numerator terms.
  % It is efficient to find them now.
  flag = true;
  p2 = p;
  while (p2 <= n) && flag
    L = mod(nst,p2);
    if L == 0
      L = p2;
    end
    % which terms will p divide?
    indn = (p2 - L + 1):p2:k;
    indn(rem(num(indn),p) ~= 0) = [];
    if ~isempty(indn)
      fc(ip,2) = fc(ip,2) + numel(indn);
      
      num(indn) = num(indn)/p;
      
      % increment the power of p yet one more time
      p2 = p2*p;
    else
      % no more powers of p may divide a num term
      flag = false;
    end
  end
end

% we can delete those prime factors in fc with a
% count of zero
fc(fc(:,2) == 0,:) = [];

% at this point, the den terms are all identically 1,
% so we can ignore them. Also ignore any numerator
% terms that are 1, as they will not contribute factors
% of the binomial cofficient.
num(num == 1) = [];
num = sort(num(:));

% the product of the elements of num should be
% nchoosek(n,k), except for any other small factors
% of the numbers in den that have been removed already. 

% many of the elements in num will be prime, but NOT
% all of them. Which ones are prime?
pn = primes(sqrt(max(num)));

% we can drop the primes already removed from pden
pn = setdiff(pn,pden);

% For each of the elements in num that remain,
% test to see if they are divisible by any of the
% potential prime factors in pn. if pn is empty,
% then all of the elements that remain in num
% must be prime themselves.
if isempty(pn)
  fc = [fc;[num,ones(numel(num),1)]];
  
elseif ~isempty(num)
  faccell = cell(numel(num,1));
  for i = 1:numel(num)
    % don't bother trying to factorize num(i)
    % unless it is divisible by one of the
    % elements of pn.
    if any(rem(num(i),pn) == 0)
      % accumulate the factors in a cell array
      % for efficiency. no pre-allocation problem.
      facnum = factor(num(i));
      faccell{i} = [facnum(:),ones(numel(facnum),1)];
    else
      faccell{i} = [num(i),1];
    end
  end
  
  % flatten the cell array, combining them with
  % the factors already in fc
  fc = [fc;cat(1,faccell{:})];
  
end

% use unique and accumarray to accumulate the factors,
% just in case any appeared more than once in fc.
% While I could have used consolidator here, fac is
% all integer, so unique will work.
[facs,I,J] = unique(fc(:,1));
facs = facs';
count = accumarray(J,fc(:,2))';

% consolidator would work too of course
% [facs,count] = consolidator(fc(:,1),fc(:,2),@sum);
% facs = facs';
% count = count';


% compute the (natural) log of nchoosek(n,k)
lognck = sum(log(facs).*count);


