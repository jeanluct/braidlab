function R = mod(a,b)
% vpi/mod: modulus after integer division of vpi objects
% usage: R = mod(a,b);
% 
% vpi/mod is consistent with double/mod when the
% signs of the arguments vary.
% 
% By convention:
% mod(a,0) is 0
% mod(a,a), for a~=0, is 0.
% mod(a,b), for a~=b and b~=0, has the same sign as b.
% 
% 
% arguments: (input)
%  a, b - vpi scalars or arrays, or any numeric
%      integer arrays
%
% arguments: (output)
%  R - a vpi object such that a = n*b + R, for
%      integer n such that n = fix(a/b).
%
%      R has the property that it will be smaller 
%      in absolute magnitude than b. R will have the
%      same sign as does a.
%
% Example:
%  
%
%  See also: quotient, rem, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 2.0
%  Release date: 3/3/09

if nargin~=2
  error('two arguments are required')
end

na = numel(a);
nb = numel(b);

if (na == 1) && (nb == 1)
  % both are scalars
  
  % ensure that b is a vpi
  b = vpi(b);

  % test for b == 0
  if iszero(b)
    % by definition, mod(a,0) = 0
    R = vpi(0);
    return
  end

  % All the work is done by quotient.
  % We could call quotient and then toss
  % Q in the bit bucket, but it is more
  % efficient to just do the work while
  % never computing Q.

  % if a numbe is no more than 2^53-1, it
  % is exactly representable as an integer
  % in double form.
  maxnum = 2^53 - 1;
  maxv = vpi(maxnum);

  if isnumeric(a) && (abs(a)<=maxnum)
    numflag1 = true;
  elseif isa(a,'vpi') && comparemagnitudes(maxv,a)
    numflag1 = true;
  else
    numflag1 = false;
  end

  if isnumeric(b) && (abs(b)<=maxnum)
    numflag2 = true;
  elseif isa(b,'vpi') && comparemagnitudes(maxv,b)
    numflag2 = true;
  else
    numflag2 = false;
  end

  % did we drop through so that both numbers can be doubles?
  if numflag1 && numflag2
    % Both can be exact doubles. These are
    % no-ops if the number was already a double.
    % see that at least one of the numbers
    % must have been a vpi to get into this
    % function in the first place.
    a = double(a);
    b = double(b);

  else
    % make sure that both are vpi objects.
    % These are no-ops if the number was
    % already a vpi.
    a = vpi(a);
    b = vpi(b);
  end

  % do the actual work. If they were both doubles,
  % then I'll just use matlab's divide operator.
  if numflag1 && numflag2
    % both are doubles here.
    R = mod(a,b);
    R = vpi(R);
  else
    % both are vpi objects. Is b a small number
    % where a decimal mod is easily computed?
    if isequal(b,10)
      % b = 10. Just peel off the units digit.
      if a.sign > 0
        R = vpi(a.digits(1));
      else
        R = vpi(10 - a.digits(1));
      end
      return
    elseif isequal(b,100)
      % b = 100. Just peel off two digits.
      if a.sign > 0
        R = vpi(a.digits(1) + 10*a.digits(2));
      else
        R = vpi(100 - a.digits(1) - 10*a.digits(2));
      end
      return
    elseif isequal(b,1000)
      % b = 1000. Just peel off three digits.
      if a.sign > 0
        R = vpi(a.digits(1) + 10*a.digits(2) + 100*a.digits(3));
      else
        R = vpi(1000 - a.digits(1) - 10*a.digits(2) - 100*a.digits(3));
      end
      return
    end

    % do a Q-less synthetic division. check
    % the magnitudes first though, since
    % if abs(a) < abs(b) then the mod is
    % trivial to compute.

    % we will do the synthetic division
    % by trying to grab a few digits at
    % a time for efficiency.
    usendigits = 13;

    % dentop will be a floating point number
    % in the half open interval [.1,1)
    dentop = tdfloat(b);
    nden = order(b);

    % inintialize the quotient and remainder
    R = a;

    % it is really just a long division
    % loop now, but done in chunks.
    while ~iszero(R) && comparemagnitudes(R,b)
      % check to see if R has gotten small enough
      % to finish the division. Remember, R must
      % still be larger in magnitude than denominator
      % since we are still in this while loop.
      nr = order(R);
      if nr <= 14
        % we can do this part with a normal divide
        % remember that R is larger in magnitude
        % then denominator, so both pieces are now
        % representable exactly as integers.
        R = mod(R,b);
      else
        % The top few significant digits of R,
        % also as a float
        Rtop = tdfloat(R);

        % the exponent applied to Qi, so that
        % Qi*R has the correct magnitude
        nq = nr - nden;

        % keep the first ndigits of the ratio
        Qi = Rtop/dentop;
        ndigits = max(1,min(usendigits,nq));
        Qi = fix(Qi * 10^ndigits);
        Qi = digitshift(vpi(Qi), nq - ndigits);

        % update R
        R = R - Qi*b;

      end
    end
  end

  % check to see the division has not given
  % us the wrong sign for R. If so, then we
  % need to add b.
  if (R.sign * sign(b)) < 0
    R = R + b;
  end
  
elseif (na == 1) && (nb > 1)
  % a is a scalar. do scalar expansion
  R = vpi(b);
  for i = 1:nb
    R(i) = mod(a,b(i));
  end
elseif (na > 1) && (nb == 1)
  % b is a scalar. do scalar expansion
  R = vpi(a);
  for i = 1:na
    R(i) = mod(a(i),b);
  end
elseif (na == 1) && (nb == 1)
  % empty propagates to empty
  R = [];
else
  % a and b are both arrays
  % verify conformability in size
  sa = size(a);
  sb = size(b);
  if ~isequal(sa,sb)
    error('a and b do not conform in size for mod operation')
  end
  R = vpi(a);
  for i = 1:na
    R(i) = mod(a(i),b(i));
  end
end
  
% ================================================
% end mainline
% ================================================
% begin subfunctions
% ================================================

function mp = digitshift(mp,k)
% shifts the decimal representation by k digits.
% if k < 0, then this is a truncation operation
if k >= 0
  mp.digits = [zeros(1,k),mp.digits];
else
  mp.digits(1:abs(k)) = [];
end

function td = tdfloat(mp)
% get the top ndigits of mp as a float
% in the half open interval [.1, 1)
ndigits = 15;
n2 = order(mp);
i = n2;
td = mp.digits(n2+1)/10;
pow10 = 10;
while (i >= 1) && (i >= (n2 - ndigits + 2))
  pow10 = pow10*10;
  td = td + mp.digits(i)/pow10;
  i = i - 1;
end
if mp.sign<0
  td = -td;
end




