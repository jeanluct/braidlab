function x = minv(a,p)
% vpi/minv: the inverse of a modulo p, such that mod(a*x,p) == 1
% usage: x = minv(a,p)
%
% if a and p are relatively prime (co-prime)
% uses the extended Euclidean algorithm to find
% a solution to the problem a*x - q*p = 1
% 
% minv returns an empty result if a and p are
% relatively prime, (also known as coprime.) A
% warning will be generated in this event.
%
% Example:
%  a = 35;
%  p = vpi(2^31 - 1);
%  ainv = minv(a,p)
%
% ainv =
%     1656630242
%
%  mod(a*ainv,p)
% ans =
%     1
%
% Example:
%  a and p must be coprime, or a warning will
%  be generated. Since no inverse exists, an
%  empty will be returned.
%
%  minv(3,15)
% Warning: a and p must be relatively prime, gcd(a,p) == 1
% ans =
%     []
%
%  See also: mod, rem
%  
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 3/6/09


if nargin~=2
  error('minv requires two arguments, a and p')
end

if isempty(a) || isempty(p)
  % propagate empty
  x = [];
  return
end

if (numel(p) > 1) || (p < 2)
  error('p must be scalar, no less than 2')
end

% make sure that a has been reduced mod p
a = mod(a,p);

% just in case p is too large. arithmetic might
% overflow the double integer limit otherwise.
if p > floor(sqrt(2^53-1))
  a = vpi(a);
end

% Is a a scalar or an array?
if numel(a) == 1
  % a is scalar
  
  % special cases
  if (a == 1) || (a == (p-1))
    % 1 and -1 are self inverses
    x = a;
    return
  elseif a == 0
    % no inverse exists for 0
    warning('MINV:zero','zero has no inverse mod p')
    x = [];
    return
  end
  
  % test that gcd(a,p) == 1
  if gcd(a,p) ~= 1
    warning('MINV:coprime','a and p must be relatively prime, gcd(a,p) == 1')
    x = [];
    return
  end
  
  % so the code will work properly for both
  % numeric and vpi numbers.
  numflag = (isnumeric(a) && isnumeric(p));
  
  % initialize the "table" for the extended
  % Euclidean algorithm
  [Riminus1,Ri] = deal(p,a);
  [Uiminus1,Ui] = deal(0,1);
  [Viminus1,Vi] = deal(1,0);
  i = 2;
  while i > 0
    if numflag
      Qiplus1 = fix(Riminus1/Ri);
      Riplus1 = mod(Riminus1,Ri);
    else
      % I could have used the same code for
      % vpi numbers as for the numeric case, but
      % this is more efficient, since quotient
      % gives both terms at once.
      [Qiplus1,Riplus1] = quotient(Riminus1,Ri);
    end
    Uiplus1 = Uiminus1 - Qiplus1*Ui;
    if Riplus1 == 1
      x = Uiplus1;
      break
    end
    Viplus1 = Viminus1 - Qiplus1*Vi;
    i = i + 1;
    
    % shift the table
    [Riminus1,Ri] = deal(Ri,Riplus1);
    [Uiminus1,Ui] = deal(Ui,Uiplus1);
    [Viminus1,Vi] = deal(Vi,Viplus1);
  end
  
  % make sure that x was reduced mod p
  x = mod(x,p);
  
else
  % a was an array
  error('minv is not supported for general arrays')
  
end

