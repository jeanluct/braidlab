function M = lcm(varargin)
% vpi/lcm: Least Common Multiple of two (or more) vpi objects
% usage: M = lcm(INT1,INT2)
% usage: M = lcm(INT1,INT2,INT3,...)
% 
% LCM(A,B) = A*B/gcd(A,B)
%
% arguments: (input)
%  INT1,INT2 - a pair of vpi scalars, or any
%      scalar numeric integers. They may even be
%      zero, although any signs will be ignored.
%      If more than two arguments are provided,
%      then the overall LCM will be generated.
% 
%      Some special cases:
%      lcm(u,0) is undefined, and will cause an error
%      lcm(u,1) = abs(u)
%      lcm(u) = abs(u)
%      lcm(u,u) = abs(u)
%
%
% arguments: (output)
%  M - The least common multiple of the inputs
%      {INT1,INT2,(INT3,...)}. M is the smallest
%      positive number that is an integer
%      multiple of all of the inputs.
%
%
% Example:
%  lcm(vpi(50),60,70,80,90)
%  ans =
%       25200
%
%  lcm(vpi(1:10))
%  ans =
%       2520
%
%  See also: gcd, quotient, rem, mod, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

switch nargin
  case 0
    error('lcm must operate on at least one argument')
  case 1
    N = varargin{1};
    % Is N a scalar or an array?
    if numel(N) > 1
      % it was an array, so compute the lcm of
      % the elements in the array. Do them all
      % sequentially.
      k = numel(N);
      M = N(1);
      for i = 2:k
        M = lcm(M,N(i));
      end
    else
      % The lcm of a scalar is the number itself.
      M = N;
    end
  case 2
    % this is the branch where all of the real
    % work is done, and that is not much more
    % than a call to gcd.
    u = vpi(varargin{1});
    v = varargin{2};
    
    % err out if either iz zero
    if (u==0) || (v==0)
      error('gcd(u,0) or lcm(0,v) is undefined')
    end
    
    M = u*(v/gcd(u,v));
    
  otherwise
    % there are 3 or more arguments. just process
    % the whole lot sequentially.
    M = lcm(varargin{1},varargin{2});
    for i = 3:nargin
      M = lcm(M,varargin{i});
    end
end

% =================================
%  end mainline
% =================================



