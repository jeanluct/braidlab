function [D,c,d] = gcd(varargin)
% vpi/gcd: Greatest Common Divisor of two (or more) vpi objects
% usage: D = gcd(INT1,INT2)
% usage: D = gcd(INT1,INT2,INT3,...)
% 
% The binary gcd algorithm is used. See
% http://en.wikipedia.org/wiki/Binary_GCD_algorithm
%
% arguments: (input)
%  INT1,INT2 - a pair of vpi scalars, or any
%      scalar numeric integers. They may even be
%      zero, although any signs will be ignored.
%      If more than two arguments are provided,
%      then the overall GCD will be generated.
% 
%      Some special cases:
%      GCD(0,0) is undefined, and will cause an error
%      GCD(u,0) = abs(u)
%      GCD(u,1) = 1
%      GCD(u) = abs(u)
%      GCD(u,u) = abs(u)
%
%
% arguments: (output)
%  D - The greatest common divisor of the inputs
%      {INT1,INT2,(INT3,...)}. D is the largest
%      (positive) number that will divide all of
%      the input arguments while leaving no remainder.
%
%
% Example:
% gcd(vpi(54637388),factorial(15))
% ans =
%    52
%
%
%  See also: lcm, quotient, rem, mod, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if false
  % JLT - first attempt to compute GCD.
  a = varargin{1};
  b = varargin{2};
  if length(a) == 1 && length(b) > 1
    a = a*vpi(ones(size(b)));
  end
  if length(a) > 1 && length(b) == 1
    b = b*vpi(ones(size(a)));
  end
  if length(a) ~= length(b)
    error('Inputs must of have same size, or one must have size 1.')
  end

  for i = 1:length(a)
    while b(i) ~= 0
      t = b(i);
      b(i) = mod(a(i),b(i));
      a(i) = t;
    end
    D(i) = a(i);
  end
  return
end

if nargout > 1
  % JLT - second attempt to compute GCD, with extra output if desired..
  a = varargin{1};
  b = varargin{2};
  if length(a) == 1 && length(b) > 1
    a = a*vpi(ones(size(b)));
  end
  if length(a) > 1 && length(b) == 1
    b = b*vpi(ones(size(a)));
  end
  if length(a) ~= length(b)
    error('Inputs must of have same size, or one must have size 1.')
  end

  for i = 1:length(a)
    s = 0; os = 1;
    t = 1; ot = 0;
    r = b(i); or = a(i);
    while ~iszero(r)
      q = or / r;
      or0 = or; or = r; r = or0 - q*r;
      os0 = os; os = s; s = os0 - q*s;
      ot0 = ot; ot = t; t = ot0 - q*t;
    end
    c(i) = os; d(i) = ot;
    D(i) = or;
  end
  return
end

switch nargin
  case 0
    error('gcd must operate on at least one argument')
  case 1
    N = varargin{1};
    % Is N a scalar or an array?
    if numel(N) > 1
      % it was an array, so compute the gcd of
      % the elements in the array. Do them all
      % sequentially.
      k = numel(N);
      D = N(1);
      for i = 2:k
        D = gcd(D,N(i));
      end
    else
      % The gcd of a scalar is the number itself,
      % or at least the abs of that.
      D = abs(N);
    end
  case 2
    % this is the branch where all of the real work is done
    u = abs(vpi(varargin{1}));
    v = abs(vpi(varargin{2}));
    
    % define some useful special functions
    iseven = @(INT) rem(INT.digits(1),2)==0;
    
    % check for some simple special cases
    zu = iszero(u);
    zv = iszero(v);
    if zu && zv
      error('gcd(0,0) is undefined')
    elseif zv
      D = u;
      return
    elseif zu
      D = v;
      return
    end
    
    % at the end, P2 will be a power of two
    % that we will multiply the result by.
    % for now, just store the exponent.
    P2 = 0;
    
    % it is a while loop now, reducing the
    % size of the numbers until one of them
    % is zero, or until u == v
    flag = 1;
    while flag
      % which of the two numbers is even?
      Eu = iseven(u);
      Ev = iseven(v);
      
      if Eu && Ev
        % both u and v are even, so just pull
        % out a factor of 2. Use the rule that
        % gcd(2*u,2*v) = 2*gcd(u,v)
        P2 = P2 + 1;
        u = divideby2(u);
        v = divideby2(v);
      elseif Eu
        % only u is even. Then gcd(2*u,v) = gcd(u,v)
        u = divideby2(u);
      elseif Ev
        % only v is even. Then gcd(u,2*v) = gcd(u,v)
        v = divideby2(v);
      else
        % both u and v are odd. Use the rule that
        % for u > v and odd u and v, then
        % gcd(u,v) = gcd((u-v)/2,v)
        if comparemagnitudes(u,v)
          % u was the larger of the two. replace u.
          u = divideby2(u-v);
        else
          % v was the larger, so replace v.
          v = divideby2(v-u);
        end
      end
      
      % are we done?
      if iszero(u)
        D = v;
        flag = false;
      elseif iszero(v)
        D = u
        flag = false;
      elseif isequal(struct(u),struct(v))
        D = u;
        flag = false;
      end
      
    end
    % multiply by 2^P2
    if P2 > 0
      D = D*(vpi(2)^P2);
    end
    
  otherwise
    % there are 3 or more arguments. just process
    % the whole lot sequentially.
    D = gcd(varargin{1},varargin{2});
    for i = 3:nargin
      D = gcd(D,varargin{i});
    end
end

% =================================
%  end mainline
% =================================

function Nover2 = divideby2(N);
% divides a vpi number N by 2, multiplies by 5 and shifts
Nover2 = N*5;
% the shift operation essentially truncates
if length(Nover2.digits) > 1
  Nover2.digits(1) = [];
end




