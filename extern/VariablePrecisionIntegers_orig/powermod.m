function R = powermod(a,d,n)
% vpi/powermod: Compute mod(a^d,n)
% usage: R = powermod(a,d,n)
% 
% powermod is MUCH faster than direct exponentiation
% with mod for large numbers. powermod does NOT
% suppoort array or vector inputs, only scalar inputs.
%
% arguments: (input)
%  a,d,n - vpi SCALAR integers, or numeric values
%
% arguments: (output)
%  R - a vpi scalar integer, representing mod(a^d,n)
%
% Example:
%  Compare exponentiation plus mod to
%  the direct application of powermod:
%
%  tic,M = powermod(vpi(123),200,497);toc
%  Elapsed time is 0.044618 seconds.
%
%  tic,M = mod(vpi(123)^200,497);toc
%  Elapsed time is 0.971667 seconds.
%
%
%  See also: power, mod, rem, quotient
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


% convert d to binary, either from a vpi
% or a double
if isnumeric(d)
  db = dec2bin(d);
else
  db = vpi2bin(d);
end
db = fliplr(db == '1');

% if a is too large, the repeated squarings will
% cause flint overflow as a double
if (a > 2^26) || (n > 2^26)
  a = vpi(a);
end

if isnumeric(a) && isnumeric(d) && isnumeric(n)
  % pure numeric
  % use the binary expansion of d to form the
  % desired power as efficiently as possible,
  % repeatedly squaring a on each pass.
  if db(1)
    R = mod(a,n);
  else
    R = 1;
  end
  for i = 2:length(db)
    if i > 2
      a2 = mod(a2*a2,n);
    else
      a2 = mod(a*a,n);
    end
    
    % do we need to multiply this power
    % of a into the result?
    if db(i)
      % take the mod on each pass through
      R = mod(R*a2,n);
    end
  end
  
else
  % use the binary expansion of d to form the
  % desired power as efficiently as possible,
  % repeatedly squaring a on each pass.
  if db(1)
    R = mod(vpi(a),n);
  else
    R = vpi(1);
  end
  for i = 2:length(db)
    if i > 2
      a2 = mod(a2*a2,n);
    else
      a2 = mod(a*a,n);
    end
    
    % do we need to multiply this power
    % of a into the result?
    if db(i)
      % take the mod on each pass through
      R = mod(R*a2,n);
    end
  end
end
