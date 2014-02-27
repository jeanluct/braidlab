function [Q,R] = quotient(numerator,denominator)
% vpi/quotient: divides two vpi objects, computing a quotient and remainder
% usage: mp = quotient(numerator,denominator);
% 
% quotient is used by the rdivide and rem functions.
% When numerator and/or demonimator represent negative
% numbers, then the quotient and remainders will be
% consistent with the signs that / and rem would return.
%
% Specifically, when numerator and denominator have
% signs as given below, then Q and R will behave as
% given by this table:
%
%  num, den, Q,   R
%  >0   >0   >0   >0
%  >0   <0   <0   >0
%  <0   >0   <0   <0
%  <0   <0   >0   <0
%  
% Quotient supports ONLY scalar inputs. NO array or
% vector arguments are supported.
%
% arguments: (input)
%  numerator,denominator - vpi scalars, or any scalar numeric integers
%
% arguments: (output)
%  Q,R - vpi objects such that numerator = Q*denominator + R
%        R has the property that it will be smaller
%        in magnitude than numerator.
%
% Example:
%
%
%  See also: rem, mod, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if nargin ~= 2
  error('Both a numerator and denominator must be supplied')
end
if (numel(numerator) ~= 1) || (numel(denominator) ~= 1)
  error('Only scalar arguments are supported')
end

% are both numerator and denominator vpi objects? If not, then
% make it so, unless both numbers are less than
% 8E15 in magnitude, in which case make them both
% doubles and use the basic tools in matlab. I've
% chosen 8e15 here, since 2^53-1 is the real
% limit, but it is easiest to just test for a
% limit of 8E15 in decimal.
maxnum = 8e15;
% can we represent numerator as a double?
if isnumeric(numerator) && (abs(numerator)<=maxnum)
  numflag1 = true;
elseif isa(numerator,'vpi') && (length(numerator.digits)<=15) && (numerator.digits(end) <= 8)
  numflag1 = true;
else
  numflag1 = false;
end

% if numflag1 can be a double, how about denominator?
if isnumeric(denominator) && (abs(denominator)<=maxnum)
  numflag2 = true;
elseif isa(denominator,'vpi') && (length(denominator.digits)<=15) && (denominator.digits(end) <= 8)
  numflag2 = true;
else
  numflag2 = false;
end

% did we drop through so that both numbers can be doubles?
if numflag1 && numflag2
  % Both are double. These are no-ops
  % if the number was already a double.
  % see that at least one of the numbers
  % must have been a vpi to get into this
  % function in the first place.
  numerator = double(numerator);
  denominator = double(denominator);
  
  % is the denominator zero?
  if denominator == 0
    error('Divide by zero')
  end
  
else
  % divides by 2, 5, or 10 will happen reasonably
  % often enough to special case them since they
  % are simpler to do than an actual divide.
  if numflag2
    if denominator == 2
      % multiply by 5, then divide by 10 using
      % shiftdec.
      
      % the remainder is zero when numerator is even
      % and +/- 1 when odd.
      R = vpi(sign(numerator)*(~iseven(numerator)));
      % shiftdec will do the divide by 10 very efficiently
      Q = shiftdec(5*numerator,-1);
      
      % all done
      return
    elseif denominator == 10
      % the remainder is just the trailing digit,
      % with the proper sign appended
      R = vpi(sign(numerator)*(trailingdigit(numerator,1)));
      % shiftdec will do the divide by 10 very efficiently
      Q = shiftdec(numerator,-1);
      
      % all done
      return
    elseif denominator == 5
      % multiply by 2, then divide by 10 using
      % shiftdec.
      
      % the remainder is a function only of the last digit
      % and the sign of numerator
      R = vpi(sign(numerator)*mod(trailingdigit(numerator,1),5));
      % shiftdec will do the divide by 10 very efficiently
      Q = shiftdec(2*numerator,-1);
      
      % all done
      return
    end
  end
  
  % make sure that both are vpi objects.
  % These are no-ops if the number was
  % already a vpi.
  numerator = vpi(numerator);
  denominator = vpi(denominator);
end

% do the actual work. If they were both doubles,
% then I'll just use matlab's divide operator.
if numflag1 && numflag2
  % both are doubles here.
  Q = fix(numerator/denominator);
  R = numerator - Q*denominator;
  
  % make the result a vpi?
  Q = vpi(Q);
  R = vpi(R);
  
else
  % both are vpi objects, so do a
  % synthetic division. check the
  % magnitudes first though, since
  % if abs(N) < abs(D) then we must
  % have Q = 0.
  
  % we will do the synthetic division
  % by trying to grab a few digits at
  % a time for efficiency.
  usendigits = 13;
  
  % dentop will be a floating point number
  % in the half open interval [.1,1)
  dentop = tdfloat(denominator);
  nden = order(denominator);
  
  % inintialize the quotient and remainder
  R = numerator;
  Q = vpi(0);
  
  % it is really just a long division
  % loop now, but done in chunks.
  while ~iszero(R) && comparemagnitudes(R,denominator)
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
      Q15 = fix(double(R)/double(denominator));
      Q = Q + Q15;
      R = R - Q15*denominator;
      
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
      
      % update Q and R
      Q = Q + Qi;
      R = R - Qi*denominator;
      
    end
  end
end

% verify that the remainder has the same
% sign as the numerator.
if (sign(numerator) ~= sign(R)) && ~iszero(R)
  % somehow, R ended up with the wrong sign in
  % all this. It is easily enough repaired. There
  % are different cases to worry about.
  if sign(denominator) ~= sign(R)
    % denominator and R have opposing signs
    R = R + denominator;
    Q = Q - 1;
  else
    % denominator and R have the same signs
    R = R - denominator;
    Q = Q + 1;
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






